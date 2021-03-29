---
title: Lambda
code: N/A
---

- Limitation
  - Duration: 15 minutes
  - Memory: Up to 3GB
  - Run preconfigured container only
  - Pay every 100ms
  - Cold start problem

#### Overview

* Run code without provisioning or managing infrastructure
* Pay per invocation: requests, GB/seconds

#### Triggers

* Directly from SDK

* Other services

  * API Gateway
  * CloudFront
  * S3
  * ...

  * 3rd-party parters: Datadog, Segment, SignalFx, Zendesk, ...

#### Interface

* Upload code: Inline, Zipfile, S3
* IAM Role (for lambda function output)
* Choose VPC

#### Limit

* 1000 concurrent lambda (Ask AWS Support for more limit)
* `/tmp` folder can contain up to 500MB
* Lambda run in no VPC. Set to VPC but lambda will lose internet connection
* Timeout up to 15 minutes
* Memory up to 3008MB, increment of 64MB

#### Cold starts

* AWS has preconfigured servers for Lambda functions. 

  When lambda function is invoked, these server need to turned on. There will be a delay when the function initially run - Cold start

* If the same function is invoked, and the servers is still running. It'll be a little delay. => Warm server

* Serverless function is cheap. But treade off with delay in user experience

* Pre Warming: strategy to keep server running continuously

  Cloud Provider are always looking for solutions to reduce Cold start

#### Function versioning

* reference to lambda function version by using ARN
  * Qualified: `arn:aws:lambda:....:function:$latest`
  * Unqualified: `arn:aws:lambda:....:function`

* Unqualified lambda cannot use alias
  * It always point to the latest version

#### Aliases

* Give the lambda function a friendlier name

#### Layers

* Put code & content as layers

  * ZIP archive
  * Can contains library, runtime environment, etc...

  => Target is make deployment package smaller, reusable, ...

  * Up to 5 layers, all layers can't exceed the unziped deployment package size limit of 250MB
  * 