---
title: AWS Cognito
code: N/A
---

## Overview

* Cognito User Pools
* Cognito Identity Pools
* Cognito Sync

## Definitions

* Web Identity Federation: việc trao đổi thông tin và security information between an identity provider (IdP) and an application
* Identity Provider (Idp): trusted provider e.g. FB, Amazon, Google, Twitter, Github, ...
* Types
  * SAML: IdP which uses SSO
  * OIDC: IdP which uses OAuth

## User pool

* Manage credentials to access the application

#### Wizard

* Custom attributes for user model

* Identity type: username, email, or phone number

* MFA

* Account recovery option

* Email sending:

  * Cognito: Limit [link](https://docs.aws.amazon.com/cognito/latest/developerguide/limits.html)

  * SES: Higher limit - Recommended for production pool

* Email customization
* Triggers: Hooks using Lambda functions

* Analytics with PinPoint
* Support IdP như Facebook, Twitter, ...

#### Notes

* After creating user pool, an app client and domain config is required to host Auth webapp
* Client can send user credentials to server to verify without opening AWS hosted webapp (using AWS SDK)
* Multiple app clients can be created

## Identity pools

* Manage credentials to access AWS resources

## Cognito Sync

* Sync user data and preference across devices
* Use push synchronization (push notification to push update)
* Use SNS to send notification when data in the cloud changes