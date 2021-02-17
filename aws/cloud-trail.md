---
title: AWS Cloud Trail
code: N/A
---

#### Overview

- Monitor API calls, or actions to AWS account
  - Where - Source IP address
  - When action is taken 
  - Who
  - What region, action, resource
- Enabled by default, last for 90 days
- Output to S3, and does not have GUI
- To analyze the log, use AWS Athena, Athena will
  - Create tables from S3 log file
  - Use SQL to query the log

* CloudTrail event can be deliveried to CloudWatch (SNS can be applied)

#### Log data

* Management events
  * Turned on by default
  * Events to be logged
    * Configuring security
    * Registering devices
    * Configuring rules for routing
    * Setting up logging
* Data events
  * High volume logging, turned off by default
  * Only S3 and Lambda can be tracked