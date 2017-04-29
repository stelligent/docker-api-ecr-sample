#!/usr/bin/env ruby

require 'docker'
require 'serverspec'

describe 'Dockerfile' do
  before(:all) do
    set :os, family: :debian
    set :backend, :docker
    set :docker_image, ENV['DOCKER_IMAGE_ID']
  end

  describe file('/usr/local/apache2/htdocs/index.html') do
    it { should exist }
    it { should be_file }
    it { should be_mode 644 }
    it { should contain('Automation for the People') }
  end

  describe port(80) do
    it { should be_listening }
  end
end
