---
title: AWS CloudFront
code: N/A
---

#### Overview

- CDN: Content Delivery Network - is a distributed network of servers which delivers content to users based on their geographical location (for best possible performance)

#### Distributions

* Distribution defines a collection of Edge Locations and behaviours how should they handle the cached contents

* Origin: S3, EC2, ELB, Route53, ...
* 2 types of distributions
  * Web
  * RTMP (for streaming media)
* Behaviours
  * Redirect to HTTPS
  * Restrict HTTP Methods
  * ... 

* Lambda@Edge Functions (Lambda function associates with CloudFront events)

  ![](https://images.viblo.asia/32f95e42-794f-4799-be63-cb33b75be8e4.png)

  * Limit to 1 function per event

#### Protection

* Allow public access by default
* Signed URL / Signed Cookies (not S3 Signed URL) is required to read private object 
  * Signed Cookies: can fetch multiple objects (e.g. video streaming)