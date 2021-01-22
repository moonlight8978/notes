---
title: AWS Kinesis
code: N/A
---

* Realtime data streaming service

* Solution for collecting, processing, and analyzing streaming data
  * Game data 
  * Stock prices
  * Click stream data
  * ...

#### Kinesis Data Stream

![](https://images.viblo.asia/0449ec36-b1cb-4501-aed7-5dbfc6892e96.png)

* Multiple consumers
* Must configure consumers manually (code)
* Data can be persisted from 24 (default) to 168 hours before it disappears from stream
* Pay for running shards

#### Kinesis Data Firehose

* One consumer from predefined list is allowed
* Data is disappears once it's consumed
* Data can be converted to a few file formats, compress and secure data
* Pay for data that is ingested

#### Kinesis Video Streams

* Output video data to ML or processing service

#### Kinesis Data Analytics

* Input: Data stream or Firehose
* Data pass through Data Analytics is running through custom SQL
* Realtime analytics of data