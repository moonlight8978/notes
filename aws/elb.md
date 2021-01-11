---
title: Elastic Load Balancer
code: N/A
---

# Application Load Balancer

* To load balance HTTP/HTTPS traffic

* Create ALB:

  * Type: internal / or public (internet facing)

  * Listener: Ports/Protocol which ALB listens to
    * Can listen to multiple ports
  * Availability zones
  * Routing: `@ref` [Target group](#Target group)

![](https://images.viblo.asia/6b35f0c0-3ce6-46c1-9d9d-b3fd4ffe8fd8.jpg)

* Rules: guide ALB to route traffic to correct resources
  * Ordering - Matcher - Processor
    * Matcher: by header, by path, ...
    * Processor:
      * Forwarding: to some target groups
      * Redirect: redirect to another url

# Target group

* Targets which ALB will forward traffic to

* Target group includes:
  * Machines which can be matched using
    * Instance (AWS-provisioned machines)
    * IP address (on-premise machines)
    * Lambda function
  * Port on each machine (use for traffic forwarding and healthcheck)
  * Health check rule (can use path without ALB rule path prefix): perform on each instance
    * ALB rules: `/devices*` forward to target group
    * Target group healthcheck: `/`
* Healthcheck fails will not affect instance state

