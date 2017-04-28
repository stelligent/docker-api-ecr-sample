#!/usr/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

CloudFormation do
  Description 'Stelligent-HTML Docker ECR Repository'

  ECR_Repository(:repository) do
    RepositoryName 'stelligent-html'
  end
end
