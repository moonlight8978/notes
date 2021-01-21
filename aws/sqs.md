---
title: Amazon SQS
code: N/A
---

* Queueing vs Streaming
  * Queueing: delete message when consumed. Does not care about what to do with message. Not real time. Have to pull, not reactive
  * Streaming: consumers react to events. Real-time. Event live in stream for long period of time.

* SQS is pull-based, not push-based.
* Usecase:
  * App publishes messages to the queue
  * Other app pulls the queue, see new message, and do something
  * Other app reports that the message is completed
  * Original app pull the queue and see the messages is no longer on the queue.
* Limitation:
  * Message size: 1B - 256KB
    * Extended Client Library for Java allow send message up to 2GB. The object will be stored in S3, and referenced to message.
  * Message retention: how long SQS hold the message
    * Default: 4 days
    * Custom: 60 seconds - 14 days
* Queue types:
  * Standard Queue: 
    * Nearly unlimited number of transactions per second
    * Guarantees that message will be delivered at least once
    * More than one copy of message will be delivered out of order
    * Provide best-effort ordering to ensure a message is delivered in the same order that it come
  * FIFO: 
    * Same capabilities as Standard Queue
    * Support ordered message
    * Limited to 300 transactions per second
* Visibility Timeout: Prevent reading message when another one is busy with that message
  * Is the time that a message will be invisible in the queue, after a reader pick up the message
    * default: 30s
    * customize: 0s - 12 hours
  * Deleted if the job is completed within visibility timeout
    * Message is visible to another app if the job is not completed in time
    * Make the message can be delivered twice potentially
* Short polling vs Long polling
  * Short polling:
    * Default
    * Returns message as soon as possible, even if the message queue being polled is empty
    * Usecase: When we need a message right away
  * Long polling:
    * Wait until messages arrives in the queue, or the long poll timeout expires
    * Reduce the number of empty receives => Inexpensive, reduce cost
    * Use for most usecase