---
title: AWS Route 53
code: N/A
---

Route53 points domain to AWS resources

* API Gateway
* ALB
* CloudFront
* ...

## Components

- Hosted zone (domain)

* Record sets (subdomain)
  * Alias: create AWS service alias
  * Routing policy: If there're multiple destinations
    * Simple: random selection
    * Weighted: route traffic based on weighted values, allows to send a certain percentage of overall traffic to one server, and have other traffic to completely different server
    * Latency-Based: route traffic to region with lowest latency
    * Failover: route traffic if primary endpoint is unhealthy to secondary endpoint
    * Geolocation: route traffic based on the location of user
    * Multivalue answer: respond to DNS queries with up to 8 healthy records selected at random. Similar to Simple policy, however with an added heath check
* Health check:
  * Every 30s by default. Can be reduced to 10s
  * CloudWatch alarm can be created to alert unhealthy
  * A health check can monitor another health check

* Resolver

## TODO:

- Resolver