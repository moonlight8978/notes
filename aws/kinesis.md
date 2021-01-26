---
title: AWS Kinesis
code: N/A
---

#### Definitions

- Data streaming

  - Is a process of sending data continuosly

  - Start/End is unknown

  - Suitable for sending data in small size in a continuous flow as the data is generated. E.g:

    - Video: because the video size is too large, streaming allow user to watch the video as soon as the server generate the video
    - Download CSV file: Generating CSV take a long time, so the user can download the file as the server generate it

    - Tracking the length of user session in website
    - Process webapp log data
    - Traffic sensor, health sensor, ... sends data as stream

- What to do with streaming data?

  - Filter
  - Correlation
  - Sampling

  => in realtime

- Event-based architecture:

  - Is a software architecture
  - Data is considered as events stream

#### Kinesis overview

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
