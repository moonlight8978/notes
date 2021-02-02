---
title: AWS Virtual Private Cloud
code: N/A
---

![](https://images.viblo.asia/c55e6ec6-36a3-4698-921b-49a2ac17f6f7.png)

* Region-specific, do not span across regions
* Up to 5 VPC per region, 200 subnet per VPC
* Cost money: NAT Gateway, VPC endpoint, VPN gateway, 
* Default VPC:
  * /16 IPv4 CIDR block
  * /20 default subnet in each AZ
  * default Internet Gateway which associate with VPC
  * Default security group
  * Default NACL
  * Default DHCP option set
  * Default main route table
* 0.0.0.0/0
* VPC Peering
  * Allow to connect 1 VPC with another VPC over a direct network using private IPs
  * Instance on peer VPC behave like they are on a same network
  * Use star configuration: 1 central - 4 others
  * No Transitive Peering: 
    * need one-to-one connect to immediate VPC
    * C <-> A <-> B: C cannot communicate with B, need C <-> B connection
  * No overlapping CIDR block
* Route table
  * Used to determine where the traffic will be directed
  * Each subnet must be associated with 1 and only 1 route table, multiple subnets can be associated to single route table
* Internet Gateway
  * Allow VPC to access with Internet
  * IGW does 2 thing:
    * Handle traffic which is internet-routable
    * Perform NAT for instance that have been assigned public IPv4
* Bastion / Jumpbox
  * Security harden
  * Access to EC2 instances which in private subnet via SSH
  * NAT Gateway/Instance is required to gain outbound access to the internet
  * Can be replaced by SSM Sessions Manager
* AWS Direct Connect: 
	![](https://images.viblo.asia/50f64bc9-56d2-495d-9c10-2af13929c42a.png)
  * establish dedicated network connections from on-premise instances to AWS
  * Very fast network (50M-500M, 1G or 10G )
  * Great traffic, reliable, and secure network
