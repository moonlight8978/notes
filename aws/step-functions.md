---
title: AWS Step Functions
code: N/A
---

#### Overview

* Coordinate multiple AWS services into a serverless workflow
* State machine model

* Types
  * Standard: general purpose - Long-duration workloads
  * Express: for streaming data - Short-duration, high-event-rate workloads
* Steps can be executed in parallel

#### Use cases

* U1: Manage a batch job

  1. Start

  2. Submit batch job (AWS Batch)

     2.1.a. Notify success (SNS)

     2.1.b. Notify failure (SNS)

  3. End

* U2: Transfer data records

  1. Start

  2. Seed the DB with users info

  3. For loop

     3.1. Read next record

     3.2. Send message to SQS

  4. Notify (SNS)

  5. End

#### States

* Pass State: dummy state (without performing work). Pass its input to its output

* Task State: represent a single unit of work performed by a state machine
  * Lambda: Resource is pass as ARN
  * Supported AWS Service: ARN, and parameters
  * Activity: worker hosted on anywhere (EC2, ECS, ...)
    * The workflow waits for an activity worker poll for a task (Activity continuously pulls waiting for a Step Function)
  * Choice State: adds branching logic
  * Wait State: delays
  * Succeed State
  * Fail State
  * Parallel State
  * Map State: complicated, iterate over an array