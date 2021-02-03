---
title: Auto Scaling Group
code: N/A
---

* Collection of EC2 instances that are treated as group for the purposes of automatic scaling & management

#### Capacity settings

- Min/Max/Desired Capacity
- Availability zone: >= 1

#### Health Check Replacements

- ASG will perform health check on EC2 instances. ASG will terminate unhealthy one and launch new instance to keep desired capacity match.
- 2 types of check
  - EC2 health check: If the instance status is one of `stopping`, `stopped`, `shutting-down`, or `terminated`, it will be considered as unhealthy
  - ELB check: Use attached load balancer to perform health check on `running` instances

#### Scaling Policies

* Scale In (Remove instances) / Scale Out (Add more instances)
* Target Tracking Scaling Policy:
  * Maintains a specific metric at a target value 
    * ALB Request Count per target, Average CPU, Average network In/Out
    * eg. If average CPU exceeds 75% then add another server

* Simple Scaling Policy (legacy, in favour of Step Scaling): scale when alarm (Cloudwatch alarm) is breached
* Step Scaling: scale when an alarm is breached, can escalates based on alarm value changing

#### ELB Integration

* Classic Load Balancers are associated directly to ASG
* Application and Network Load Balancers are associated indirectly via their Target Groups

#### Launch Configuration

- Template for ASG to launch an instance
  - EC2 settings (storage, instance type, role, ...)
- Launch Templates are Launch Configurations with Versioning 