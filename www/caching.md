---
title: Caching
code: N/A
---

#### Browser caching

* Cache control: How cache will be stored

  * `private`: cache can be stored, but on user device only, not on CDN.
  * `public` can be cached everywhere

* ETag: identifier of resource version

* Expires: Cache resource expiration time

* Vary: determine cache is valid or not

  `Vary: User-Agent, Accept-Language`: means a cached version must exist for each combination of `User-Agent` and `Accept-Language`

#### Proxy caching

* aka CDN

