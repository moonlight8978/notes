---
title: AWS CloudFormation
code: N/A
---

#### Overview

- IaC: Infrastructure as Code
- AWS Quick Starts: Collection of prebuilt CloudFormation stacks

#### Template Formats

* Metadata & Description

```yaml
AWSTemplateFormatVersion: 2010-09-09
Description: Launch simple webpage
```

* Parameters: values to pass to template at runtime

```yaml
Parameters:
	InstanceType:
		Description: EC2 instance type
		Type: String
		Default: t2.micro
		AllowedValues:
			- t2.nano
			- t2.micro
```

* Resources: resources to create, eg. IAM roles, EC2 instances, Lambda functions, RDS, ... Required at least 1 resource

```yaml
Resources:
	WebServer:
		Type: 'AWS::EC2::Instance'
		Properties:
			Tags:
				- Key: Name
					Value: Apache default webserver
			InstanceType: !Ref InstanceType
			ImageId: 'ami-xxx'
			SecurityGroupIds:
				- !GetAtt SecurityGroup.GroupId
			UserData:
				'Fn::Base64':
					!Sub |
					#! /usr/bin/env bash
					su ec2-user
					sudo yum install httpd-y
					sudo service httpd start
	SecurityGroup:
		Type: 'AWS::EC2::SecurityGroup'
		Properties:
			GroupDescription: Enable internet users to access.
			SecurityGroupIngress:
				- IpProtocol: tcp
					FromPort: 80
					ToPort: 80
					CidrIp: 0.0.0.0/0
```

* Outputs: values that returns, to print to console, eg. Created server IP address'

```yaml
Outputs:
	PublicIp:
		Value: !GetAtt WebServer.PublicIp
```

#### Update stack

* When template format is modified and pushed. CloudFormation will intelligently change or remove/recreate the resources

* Direct Update:
  * Update stack directly, and CloudFormation will immediately deploys them
  * Use when want to quickly deploy
* Execute change set: 
  * Changes can be reviewed, after being confirmed, CloudFormation will deploys the changes
  * Manual confirmation is required

* Update strategies:

  * Update with No Interruption
    * Update without Disrupting operation
    * Without changing the resource physical ID
  * Update with Some Interruptions
    * Update the resources with some interruptions
    * Retains the physical ID
  * Replacement
    * Recreate resources during the update
    * Generate new physical ID

* Prevent Update Stacks:

  * Prevent data loss or interruption to the service (eg. Database)

  * Use StackPolicy

#### Nested Stack

* Allows to reference CFN templates to another CFN templates
  * Modular templates (reusability)
  * Assemble large templates (reduce complexity)

 ```yaml
AWSTemplateFormatVersion: 2010-09-09
Resources:
	MyStack: 
		Type: AWS::CloudFormation::Stack
		Properties:
			TemplateURL: https://s3.abc.xyz/..../xxx.template
			TimeoutInMinutes: '60'
 ```

#### Drift detection

* When stack's actual config differs (has drifted) by what CloudFormation expected
  * Developer make changes manually instead of modify the templates
  * CloudFormation can detect drift and inform the user if resources have been deleted or modified
    * `DELETED`, `MODIFIED`, `NOT_CHECKED`, and `IN_SYNC` 
* CloudFormation does not detect drift on any nested resource, run drift detection directly on nested template instead

#### Rollbacks

* Turned on by default, can be turned off by using `--ignore-rollback` via AWS CLI
* Occured by:
  * Syntax errors
  * Resources trying to delete is no longer exists
* `ROLLBACK_IN_PROGRESS`, `UPDATE_ROLLBACK_COMPLETE`, `UPDATE_ROLLBACK_FAILED`

#### Pseudo parameters

* Parameters are predefined by AWS

* Use `Ref` function

  ```yaml
  Outputs:
  	StackRegion:
  		Value: !Ref "AWS::Region"
  ```

* `AWS::Partition`, `AWS::Region`, `AWS::StackId`, `AWS::StackName`, `AWS::URLSuffix`

 #### Resources Attributes

* CreationPolicy: prevent its status from reaching create complete until CFN receives a specific number of success signals or timeout is exceeded.

  ```yaml
  Resources:
  	SimpleASG:
  		Type: AWS::AutoScaling::AutoScalingGroup
  		CreationPolicy:
  			ResourceSignal:
  				Count: 3
  				Timeout: PT15M
  ```

* DeletionPolicy: reverse or backup a resource when stack is deleted

  * `Delete`, `Retain`, or `Snapshot`

  ```yaml
  Resources:
  	SimpleDB:
  		Type: AWS::RDS::DBInstance
  		DeletionPolicy: Retain
  ```

* UpdatePolicy: only for ASG, ElastiCache, Domain, and Lambda Alias

  ```yaml
  UpdatePolicy:
  	AutoScalingReplacingUpdate:
  		WillReplace: True
  ```

* UpdateReplacePolicy: to retain or backup the existing physical insatnce of a resource when it is replaced during a stack update operation

  * `Delete`, `Retain`, or `Snapshot`

  ```yaml
  Resources:
  	SimpleDB:
  		Type: AWS::RDS::DBInstance
  		UpdateReplacePolicy: Retain
  ```

* DependsOn: the resource will be created only after the creation of the resources in DependsOn

  ```yaml
  Resources:
  	SimpleEC2Instance:
  		Type: AWS::EC2::Instance
  		DependsOn: SimpleDB
  	SimpleDB:
  		Type: AWS::RDS::DBInstance
  ```

#### Intrinsic Functions

* Assign value at runtime

| Functions                          | Purpose                                              |
| ---------------------------------- | ---------------------------------------------------- |
| `Fn::Base64`                       | base64 representation of the input string            |
| `Fn::Cidr`                         | Returns an array of CIDR address blocks              |
| `Fn::And`/`Equals`/`If`/`Not`/`Or` | Condition functions                                  |
| `Fn::Join`                         | Joins strings by delimiter                           |
| `Fn::Select`                       | Select object by index                               |
| `Fn::Sub`                          | Substitues                                           |
| **`Fn::GetAtt`**                   | Returns resource attribute value                     |
| **`Ref`**                          | returns the value of specified parameter or resource |
| ...                                |                                                      |

* `Ref`

  * Returns different things for different resources (lookup in the AWS Docs): eg. ARN, Resource Name, Physical ID

  * If a value for a resource can't be get from `Ref`, using `Fn::GetAtt`

* `Fn::GetAtt`

  * Allow to access many different variables on a resource `!GetAtt SecurityGroup.GroupId`, ....

#### Wait Conditions

* 2 use cases:
  * To coordinate stack resource creation with configuratoin actions that are external to the stack creation
  * To track the status of a configuration process

```yaml
WebServer:
	Type: AWS::EC2::Instance
	Properties:
		UserData:
			Fn::Base64:
				Ref: WaitHandle
		ImageId: ami-xxx
WaitHandle:
	Type: AWS::CloudFormation::WaitConditionHandle
WaitCondition:
	Type: AWS::CloudFormation::WaitCondition
	DependsOn: WebServer
	Properties:
		Handle:
			Ref: WaitHandle
    Timeout: '300'
    # Count: 
```

* `cfn-signal` helper script can be used in order to signal success to a wait conditoin

* `WaitCondition` is similar to `CreationPolicy` for EC2, and ASG
  * CreationPolicy: waits onthe dependent resources
  * WaitCondition: waits on the wait conditoin (external)