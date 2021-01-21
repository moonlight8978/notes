---
title: AWS Simple Notification Service
code: N/A
---

- Pub-Sub

  - Publishers push events to SNS
  - Subscribers receive push event

- Topic:

  * Communication channel

  - Encrypt via KMS

- Subscriber:

  - Protocol: 
    - HTTP(S): send push request
    - Email
    - Amazon SQS: create SQS message
    - Lambda: trigger lambda function
    - SMS: send text message
    - Platform application endpoint: Mobile Push