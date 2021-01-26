---
title: DynamoDB
code: N/A
---

#### Overview

- NoSQL, key-value and document database
- Pay for capacity, no need to worry about infrastructure
  - Read capacity: RCU
  - Write capacity: WCU

* All data is stored on SSD storage and is spread across 3 different AZs

#### Read consistency

* Data is copied to 3 AZs => It is possible for data being inconsistent during copying

###### Eventual Consistent Reads (DEFAULT)

* When data is updated, it is possible to read and return an inconsistent copy

* Read is fast but there is no guarantee of consistent
* Time taken by data to be consistent is about 1 second

###### Strongly Consistent Reads

* When data is being updated, it will not return until all copies are consistent
* Guarantee of consistent, but high latency (slower)

#### DynamoDB Partitions

* Partition is an allocation of storage for a table, automatically replicated across multiple AZs
  *  Slice table into smaller chunk of data (a partition)
  * Speeds up reads

* Automatically created as the growth of data
* 2 cases when a partition will be created
  * Every 10GB of data
  * RCUs (3000) or WCUs (1000) is exceed for a single partition

#### Primary keys

* Determine **how and where** data will be stored in partition

* Cannot be changed

* Partition key: which partition should be written to

  Sort key: How data should be sorted on partition

  Data type: Number, String, and Binary

* Using only partition key: Simple primary key

  Using both partition key and sort key: Composite Primary Key

###### Simple Primary Key

- Data (Partition Key + Value) => Internal Hash Function => Partition

###### Composite Primary Key

- Data (Partition Key + Sort key + Value) => Internal Hash Function => Partition
- The combination must be unique
- Same partition key => Same parition, sorted A-Z

###### Primary Key Design

* As distinct as posible
* Should evenly divide data

#### Query and scan

###### Query

- Find items based on primary key value
- Query any table or secondary index that has a composite primary key
- Eventual Consistent Read by default (changable)
- Returns all attributes by default (changable)
- Sort ASC by default (changable)

###### Scan

* Scan through all items, then returns 1 or more items using filter
* Return all attributes by default
* Can be performed on tables or secondary indexes
* Scan operations are sequential. Speed up scan through parallel scans using Segment and TotalSegments
* Should be avoid when possible
  * Query is much effecient
  * Take longer time as the growth of table
  * Single scan can burn all provisioned throughput

#### Provisioned Capacity

* Is the maximum amount of read/write operations per second from a table or index: RCUs, WCUs
* Get `ProvisionedThroughputExceededException` when go beyond (throttling)
  * Requests that are throttled will be dropped, result in data loss

###### On-demand

* Pay for what you used
* The throughput is limited by the default upper limit for a table: 40.000 RCUs/WCUs
* There's no hard limit imposed by the user

#### Calculating Read/Write

###### RCUs

* Represents:

  * 1 strongly consistent read per second, or 2 eventual consistent reads per second
  * for an item up to 4KB in size

* Example:

  * 10RCUs: 10 (1x10) SCRs or 20 (2x10) ECRs per seconds at 4 (4x1) KB (or less) per item

* Calculating:

  |                           |         SCR         |              ECR              |
  | ------------------------- | :-----------------: | :---------------------------: |
  | 50 Reads at 40KB per item | (40 / 4) * 50 = 500 |    (40 / 4) * 50 / 2 = 250    |
  | 10 Reads at 6KB per item  |  (8 / 4) * 10 = 20  |     (8 / 4) * 10 / 2 = 10     |
  | 33 Reads at 17KB per item | (20 / 4) * 33 = 165 | (20 / 4) * 33 / 2 = 82.5 ~ 83 |


###### WCUs

* Represents:
  * 1 write per second
  * for an item up to 1KB
* Example: 10WCUs = 10 write per second at 1KB (or less) per item
* Calculating:
  * 50 writes at 40KB per item: 50 * 40 = 2000 WCUs

#### Global Tables

* Multi-region, multi-master database
* Requires:
  * KMS CMK
  * Enable Streams
  * Stream Type of New and Old image

#### Transaction

* Using `TransactWriteItems`, and `TransactReadItems` allow for all-or-nothing changes to multiple items both within and across tables
* DynamoDB performs 2 read and write of every item in the transaction (visible in CloudWatch metrics)
  1. one to prepare the transaction
  2. one to commit the transaction

#### Time to live (TTL)

* TTL let the item in DynamoDB expire in the given time
* Keep database small, manageable, suited for temporary continuous data
  * Session data, event log, ...

#### DynamoDB Streams

* Modification is captured and send to Lambda function
  * Sent in batch
  * Near real-time
  * Stream records appear in the same sequence as the actual modifications

#### Errors

* `ThrottlingException`: `CreateTable`, `UpdateTable`, and `DeleteTable` too rapidly
* `ProvisionedThroughputExceededException`:
  * AWS SDK will retry automatically 

#### DynamoDB indexes

* 2 types

  * Global Secondary Index: GSI
    * Cannot provide strong consistency
    * The query on the index can across all partitions of the table
    * No size restriction
    * Have their own throughput settings
    * Limit to 20 per table (default)
    * Can be added or deleted at anytime
    * The partition key should be different from the base table
    * The sort key is optional
    * Can only request the attributes that are projected to the index
  * Local Secondary Index: LSI
    * Can provide strong consistency
    * Every partition of an LSI is scoped to a base table partition that has the same partition key value
    * The total size of indexed items for any one partition key value cannot exceed 10GB
    * Up to 5 LSI per table (default)
    * Shares provisioned throughputs for R/W with the table it is indexing
    * Created with the initial table, and cannot be added or deleted after creation
    * LSI need both partition key (must be the same as the base table) and sort key (should be different from the base table)
    * Query one partition of table

  => GSI is recommended over LSI (?)

#### DynamoDB Accelerator (DAX)