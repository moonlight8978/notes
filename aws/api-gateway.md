---
title: AWS API Gateway
code: N/A
---

#### Overview

* Front door for applications to access data from backend services
* Handle traffic management, authorization, and monitoring
  * Track API usage, throttle to prevent attacks
  * Scalable
  * API versioning‹
  * Expose HTTPS endpoints
* Types‹
  * HTTP API
  * REST API (Public / Private)
  * Websocket API

#### Configuration

* Resources, Methods
  * /products
    * POST, GET, ...
* Stages: Versions
  * prod, qa, staging, ...
* Integration type:
  * Lambda: Integrate with lambda function
  * HTTP: forward request to integration target
  * AWS Service: must be set up after creation
    * Private resource: ALB, NLB, CloudMap, ...
    * AWS Service: SQS, Kinesis, AppConfig, Step Functions, Event Bridge

#### Caching

* Cache API responses for a specific time (TTL)

#### CORS

#### Predefined Routes

Each API has predefined routes

* HTTP API: `$default`
* Websocket API: `$connect`, `$disconnect`, `$default`
* ...

#### Websocket

* [Link](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-websocket-api-overview.html)

* Using HTTP or Lamda (or DynamoDB) integrations

* Incoming JSON messages are directed to backend integrations based on routes that be configured

* By default `$connect` route being called when a persistent connection is initiated

  And `$disconnect` called when aclient or the server disconnects from the API

  

  

