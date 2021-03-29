---
title: AWS Elasti Cache
code: N/A
---

#### Overview

Caching:

* Temporary storage data

- Trade off durability with speed.

In-Memory Data Store:

* Store data in RAM
* Very high speed. Not durable.

ElastiCache:

* Run scalable in-memory data stores

* Accessible within VPC to ensure low latency

* Supports: 

  * Memcached: Simple. Key/value. Super fast. Preffered for caching HTML
  * Redis: Richer data & operations. Preffered for leaderboards, keep track of unread notifications, .... Arguably not as fast as Memcached

  TODO: Usecase memcached, and redis

* Redis cluster mode can be enabled to achieve high availability