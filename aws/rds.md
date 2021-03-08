---
title: RDS
code: N/A
---

- Must create database subnet group which contains multiple subnets (for multi AZ purpose)

#### Encryption

* Encrypted at rest can be enabled
  * Using KMS key
  * Encrypt the automated backups, snapshots, and read replicas as well.

#### Backups

* Automated Backup:
  * Retention Periods: 1-35 days
  * All data stored in S3
* Manual Backup:
  * Take snapshot manually

#### Recovering

* Allows restoring a DB instance to a specified time
* Backup data is never restored overtop the existing instance
* Restored RDS instances will have new DNS endpoint

#### Multi AZ

* Sync: durable, reliable

* A Standby slave is placed on different availability zone (single region)

* Use for high Availability / Failover
  * When Master down, Slave is promoted to Master

#### Read Replicas

* Async: scalable

* Different to Multi AZ
  * Read Replicas is for Read scalability. Replica is not promoted automatically, and must be done manually
* Automatically backup must be enabled to use Read Replicas
* Up to 5 replicas of a database
* Multi AZ, Cross region replicas, replica of replica is supported

#### Reserved Instances

* Long-term usage, better price than On-demand instances

#### Snapshot

- Copy: Copy to another region
- Migrate: Migrate to another DB engine (Aurora)

* Unerypted snapshot can not be restored to encrypted database, it must be copied to encrypted one first

#### Aurora Serverless

* Good for unpredictable workload
* Config ram & storage