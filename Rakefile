#!/usr/bin/env ruby

require 'aws-sdk-core'
require 'base64'
require 'docker'
require 'cfndsl'

@image_id_path = 'stelligent-html-image-id'
@stack_name = 'STELLIGENT-HTML-DOCKER-SAMPLE-ECR-REPO'

desc 'Create ECR repository'
task 'ecr:create-repository' do
  cloudformation_client = Aws::CloudFormation::Client.new

  cloudformation_client.create_stack(
    stack_name: @stack_name,
    template_body: CfnDsl.eval_file_with_extras('cfn/ecr-repo.rb', {}).to_json
  )

  cloudformation_client.wait_until(:stack_create_complete,
                                   stack_name: @stack_name)
end

desc 'Delete ECR repository'
task 'ecr:delete-repository' do
  cloudformation_client = Aws::CloudFormation::Client.new

  cloudformation_client.delete_stack(
    stack_name: @stack_name
  )

  cloudformation_client.wait_until(:stack_delete_complete,
                                   stack_name: @stack_name)
end

desc 'Authenticate with ECR'
task 'ecr:authenticate' do
  ecr_client = Aws::ECR::Client.new

  if ENV['AWS_ACCOUNT_ID'].nil?
    raise 'MissingAccountNumber', \
          'Set environment variable AWS_ACCOUNT_ID and try again.'
  end

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
end

desc 'Build stelligent-html image'
task 'stelligent-html:build' do
  image = Docker::Image.build_from_dir(
    '.',
    'dockerfile' => 'Dockerfile', 't' => 'stelligent-html:latest'
  )

  File.write(@image_id_path, image.id)

  puts "Image build with ID #{image.id}"
end

desc 'Tag stelligent-html image'
task 'stelligent-html:tag' do
  image = Docker::Image.get(File.read(@image_id_path))

  image.tag(repo: 'stelligent-html', tag: 'sample')
end

desc 'Push stelligent-html image'
task 'stelligent-html:push' do
  image = Docker::Image.get(File.read(@image_id_path))

  image.push
end
