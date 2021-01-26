---
title: AWS Secrets Manager
code: N/A
---

#### Creating wizard

* DB credentials: 
  * Enter username, and password
  * Choose DB endpoint
* Other:
  * Store by key value, or plaintext (with json format for example)

#### Automation rotation

* Performed via Lambda function

#### Use cases

* Secret Manager => Lambda (specific period of time) => RDS (change credentials)
* Instance (or Developer) => Secret Manager (get secrets) => RDS (connect)

