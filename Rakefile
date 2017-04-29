#!/usr/bin/env ruby

require 'aws-sdk-core'
require 'base64'
require 'docker'
require 'cfndsl'
require 'rake'
require 'rspec/core/rake_task'

@image_id_path = 'stelligent-html-image-id'
@ecr_repo_url_path = 'stelligent-html-ecr-repo'
@stack_name = 'STELLIGENT-HTML-DOCKER-SAMPLE-ECR-REPO'

desc 'Run demo start to finish and cleanup'
task 'stelligent-html:demo' do
  if ENV['AWS_ACCOUNT_ID'].nil?
    raise 'Set environment variable AWS_ACCOUNT_ID and try again.'
  end

  %w[
    ecr:create-repository
    stelligent-html:build
    stelligent-html:test
    stelligent-html:tag
    stelligent-html:push
    ecr:delete-repository
    stelligent-html:cleanup
  ].each do |task_name|
    Rake::Task[task_name].reenable
    Rake::Task[task_name].invoke
  end
end

desc 'Create ECR repository'
task 'ecr:create-repository' do
  cloudformation_client = Aws::CloudFormation::Client.new

  # Create CloudFormation stack for our ECR repo
  cloudformation_client.create_stack(
    stack_name: @stack_name,
    template_body: CfnDsl.eval_file_with_extras('cfn/ecr-repo.rb', {}).to_json
  )

  cloudformation_client.wait_until(:stack_create_complete,
                                   stack_name: @stack_name)

  puts "Cloudformation Stack: #{@stack_name} created."
end

desc 'Delete ECR repository'
task 'ecr:delete-repository' do
  cloudformation_client = Aws::CloudFormation::Client.new
  ecr_client = Aws::ECR::Client.new

  image_ids = ecr_client.list_images(
    registry_id: ENV['AWS_ACCOUNT_ID'],
    repository_name: 'stelligent-html'
  ).image_ids

  # Delete all the pushed images (prerequisite for deletion)
  ecr_client.batch_delete_image(repository_name: 'stelligent-html',
                                image_ids: image_ids)

  # Delete the stack
  cloudformation_client.delete_stack(
    stack_name: @stack_name
  )

  cloudformation_client.wait_until(:stack_delete_complete,
                                   stack_name: @stack_name)

  puts "Cloudformation Stack: #{@stack_name} deleted."
end

desc 'Authenticate with ECR'
task 'ecr:authenticate' do
  ecr_client = Aws::ECR::Client.new

  # Grab your authentication token from AWS ECR
  token = ecr_client.get_authorization_token(
    registry_ids: [ENV['AWS_ACCOUNT_ID']]
  ).authorization_data.first

  # Remove the https:// to authenticate
  ecr_repo_url = token.proxy_endpoint.gsub('https://', '')

  # Authorization token is given as username:password, split it out
  user_pass_token = Base64.decode64(token.authorization_token).split(':')

  # Call the authenticate method with the options
  Docker.authenticate!('username' => user_pass_token.first,
                       'password' => user_pass_token.last,
                       'email' => 'none',
                       'serveraddress' => ecr_repo_url)

  File.write(@ecr_repo_url_path, ecr_repo_url)

  puts "Authenticated: #{ecr_repo_url} with with Docker on this machine."
end

desc 'Build stelligent-html image'
task 'stelligent-html:build' do
  image = Docker::Image.build_from_dir(
    '.',
    'dockerfile' => 'Dockerfile', 't' => 'stelligent-html:latest'
  )

  File.write(@image_id_path, image.id)

  puts "Image: #{image.id} built."
end

desc 'Tag stelligent-html image'
task 'stelligent-html:tag' do
  image = Docker::Image.get(File.read(@image_id_path))

  # Authentication is required for this step
  if Docker.creds.nil?
    Rake::Task['ecr:authenticate'].reenable
    Rake::Task['ecr:authenticate'].invoke
  end

  ecr_repo = "#{File.read(@ecr_repo_url_path)}/stelligent-html"

  image.tag(repo: ecr_repo, tag: 'sample')

  puts "Image: #{image.id} has been tagged: #{image.info['RepoTags'].last}."
end

desc 'Test stelligent-html image'
RSpec::Core::RakeTask.new('stelligent-html:test') do |t|
  ENV['DOCKER_IMAGE_ID'] = File.read(@image_id_path)
  t.pattern = 'spec/integration/docker/*_spec.rb'
end

desc 'Push stelligent-html image'
task 'stelligent-html:push' do
  image = Docker::Image.get(File.read(@image_id_path))
  ecr_repo = "#{File.read(@ecr_repo_url_path)}/stelligent-html"
  repo_tag = "#{ecr_repo}:sample"

  # Authentication is required for this step
  if Docker.creds.nil?
    Rake::Task['ecr:authenticate'].reenable
    Rake::Task['ecr:authenticate'].invoke
  end

  image.push(nil, repo_tag: repo_tag)

  puts "Tag: #{repo_tag} pushed to ECR."
end

desc 'Clean demo resources'
task 'stelligent-html:cleanup' do
  image = Docker::Image.get(File.read(@image_id_path))

  image.remove(force: true)

  File.delete(@image_id_path)
  File.delete(@ecr_repo_url_path)

  puts "Image: #{image.id} removed from this machine."
end
