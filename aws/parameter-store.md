---
title: AWS SSM Parameter Store
code: N/A
---

#### Overview

* Secure, hierarchical storage for configuration data and secrets management

#### Creating wizard

* Name: `/a/b/c/d/e`
* Tier:
  * Standard: 
    * Up to 10.000 parameters. 
    * Parameter value size up to 4KB
    * Policy are not avaliable
  * Advanced:
    * More than 10.000 parameters (100.000)
    * Value size up to 8KB
    * Policy are available
    * Charges apply

* Type: 
  * String
  * StringList: seperated by comma
  * SecureString: Encrypted by KMS
* No auto rotation

#### Parameter Policy

* Expiration: parameter will be deleted after a specific date and time
* ExpirationNotification: notify about next expiration
* NoChangeNotification: notify if a parameter has not been modified for a specified period of time

#### CLI

```bash
aws ssm put-parameter --name '/default-dev/db/username' --value username --type String
aws ssm put-parameter --name '/default-dev/db/password' --value password --type String
```

```bash
aws ssm get-parameters-by-path --path /default-dev/db
# => {
#   "Parameters": [
#     {
#       "Name": "/default-dev/db/password",
#       "Type": "String",
#       "Value": "username",
#       "Version": 1,
#       "LastModifiedDate": "2021-01-25T14:52:52.888000+07:00",
#       "ARN": "arn:aws:ssm:us-east-1:xxx:parameter/default-dev/db/password",
#       "DataType": "text"
#     },
#     {
#       "Name": "/default-dev/db/username",
#       "Type": "String",
#       "Value": "password",
#       "Version": 1,
#       "LastModifiedDate": "2021-01-25T14:52:35.642000+07:00",
#       "ARN": "arn:aws:ssm:us-east-1:xxx:parameter/default-dev/db/username",
#       "DataType": "text"
#     }
#   ]
# }

```

#### Practical notes

* Integration
  * ECS: passed as ENV on container's runtime
  * Terraform: supported
  * Custom: Rails initializes (get parameters and assign to ENV)

