---
title: CI/CD
code: N/A
---

## CodeCommit

- Git-based
- Encrypted at rest as well as in transit
- Access:
  - Add SSH key to IAM user => returns `SSH key ID` (remote user)
  - Use HTTPS credentials

## CodeBuild

* Database can be created using Docker

##### Versions

- `0.1`: runs each build command in seperated instance
- `0.2`: runs all build commands in single instance

##### Phases

*  install
* pre_build
* build
* post_build

## CodeDeploy

##### Overview

* Fully managed deploy pipeline
* Use cases
  * Deploy EC2, on-premise instances, Lambda, or ECS

* In-place or Blue/Green deployment
* Integrate with many tools: Jenkins, CodePipeline, Puppet, Chef, Ansible, ...

##### Core Components

* Application: Unique identifier for the application being deployed. 
* Deployment Groups: A set of EC2 instances or Lambda functions where the new revision is deployed to
* Deployment: This is the process, and components used to apply new revision
* Deployment Configuration: A set of deployment rules, with success/failure conditions included
* AppSpec file: Deployment actions that CodeDeploy should execute during deployment

* Revision: the changes

##### In-place deployment

* The app on each instance in the deployment group is stopped
* The latest app revision is installed, started, and validated
* Load balancer can be used to deregister instance during its deployment, and register back after the deploy is completed

* Can only be used on EC2 (single instance / auto scaling group), or On-premise

##### Blue/Green deployment

* Environment config:
  * Automatically copy EC2 ASG: 
  * Manually provision instances: 
* Instances are provisioned for the replacement environment
* The latest application revision is installed on the replacement instances
* Optional wait time: Application testing, system verification
* Replacement environment will be registered with an ELB, old environment will be deregistered

##### AppSpec file

##### CodeDeploy Agent

* EC2 instance need CodeDeployAgent, so the instance can report the progression back to CodeDeploy
* Service Role may required based on our deployment strategy

## CodePipeline

* Represent all components
* Stage represent a step. Common steps: Source > Build > Deploy (support many platforms/services)