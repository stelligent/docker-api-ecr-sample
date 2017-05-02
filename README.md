# docker-api-ecr-sample

This project contains a lightweight sample of how to use Docker, Amazon ECR and the swipely/docker-api to perform your Docker pipeline tasks in a testable environment with Ruby.

# Read about this on Stelligent's Blog
Check out the blog post that pairs with this demo here:

https://stelligent.com/2017/05/02/docker-lifecycle-automation-and-testing-with-ruby-in-aws/

# Requirements
* Ruby 2.3 +
* Bundler `gem install bundler`
* Amazon AWS Account with credentials configured

# Demo
Demo duration: approximately 5 minutes.

```bash
$ bundle install
$ export AWS_ACCOUNT_ID=1234567890 # required for ECR
$ rake stelligent-html:demo
```

This rake task will perform the following:
1. Create a CloudFormation Stack with a sample ECR Repository
2. Build the sample docker image
3. Test the docker image
4. Tag the docker image for ECR
5. Push the docker image to ECR
6. Clean up your ECR repository
7. Delete the CloudFormation Stack
8. Cleanup / Delete sample image

# Rake tasks for the adventurous

| Task Name | Description |
|-----------|-------------|
| ecr:authenticate         | Authenticate with ECR |
| ecr:create-repository    | Create ECR repository |
| ecr:delete-repository    | Delete ECR repository |
| stelligent-html:build    | Build stelligent-html image |
| stelligent-html:cleanup  | Clean demo resources |
| stelligent-html:demo     | Run demo start to finish and cleanup |
| stelligent-html:push     | Push stelligent-html image |
| stelligent-html:tag      | Tag stelligent-html image |
| stelligent-html:test     | Test stelligent-html image |
