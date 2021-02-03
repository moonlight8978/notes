---
title: Elastic Load Balancer
code: N/A
---

#### Overview

- Can be physical hardware or virtual software that accepts incoming traffic, and then distribute the traffic to multiple targets
- 3 type of ELB
  - Application Load Balancer (HTTP/HTTPS)
  - Network Load Balancer (TCP/UDP)
  - Classic Load Balancer (Legacy)

#### Rules of Traffic

- Listeners

  - Listener evaluate any incoming traffic that is matches the Listener's port

- Rules

  - Listener invoke rules to decide what to do with the traffic
  - Listener's target is often a Target Group (or redirect to another site)

- Target group

  - EC2 instances are registered as targets to a Target Group

  - Target group includes:
    - Machines which can be matched using
      * Instance (AWS-provisioned machines)
      * IP address (on-premise machines)
      * Lambda function
    - Port on each machine (use for traffic forwarding and healthcheck)
    - Health check rule (can use path without ALB rule path prefix): perform on each instance
      * ALB rules: `/devices*` forward to target group
      * Target group healthcheck: `/`
  - Healthcheck fails will not affect instance state, ELB will not route the traffic to that instance

- For CLB, traffic is sent to Listeners, then it forwards the traffic to any registered EC2 instances. No rules is applied

#### Application Load Balancer

* To load balance HTTP/HTTPS traffic (Layer 7 load balancer)

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

#### Network Load Balancer

- Handle TCP/UDP traffic (Layer 4 LB)
- Cross-zone Load Balancing
- Suitable for Multiplayer Game, or when network performance is critical

#### Classic Load Balancer

* Can balance HTTP/HTTPS (Layer 7) or TCP traffic (Layer 4) (not at the same time)
* Cross-zone Load Balancing
* 504 response is returned if the underlying application is not responding
* Deprecated

#### Sticky sessions

* Use cookie (Layer 7)

* Advanced load balancing method that allows us to bind a user's session to a specific EC2 instance
* Ensure all requests from that session are sent to the same instance
* Typically utilized with a CLB
* Can be enabled for ALB, but can only be set on a Target Group instead of individual EC2 instances

* Useful when specific information is only stored locally on a single instance (stateful app)

#### X-Forwarded-For (XFF) header

- Represent user IPv4 address

#### Cross-Zone Load Balancing

- Normally, the load balancer route traffic to the targets in the same AZ
- At least 2 subnet (only 1 subnet per AZ) => 2 AZ must be choosen to increase the availability of the LB
- When Cross-Zone Load Balancing is enabled (on CLB or NLB), the traffic will be distrubuted evenly across all AZ
- 