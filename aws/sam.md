---
title: AWS Serverless Application Model
code: N/A
---

* SAM is a combination of lambda functions, event sources, and other functions that work together to perform tasks (without server).

* CloudFormation macro:

  * Macro: is a replacement output sequence according to a defined procedure

  * Backed by CloudFormation using `Transform` attribute:

    ```yaml
    Transform: AWS::Serverless-2016-10-31
    ```

    * `AWS::Serverless::Function`, `AWS::Serverless::API`, `AWS::Serverless::SimpleTable`

* Using SAM will reduces CFN template's LOC 

* SAM CLI: makes it easy to run, package, and deploy Serverless Applications and Lambda functions