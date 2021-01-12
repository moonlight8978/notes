---
title: AWS KMS
code: N/A
---

## Overview

- Create, control, and rotate encription keys

* Multi-tenant (cho nhiều người thuê cùng 1 thiết bị) **Hardware Security Module**
  * Hardware that is specialized for storing encryption keys
  * Stores keys in-memory, so the keys are never written to disk

* CloudHSM: managed, full-control HSM

## Master key

- Master key is used to create (ecrypt) data key
- Data key is used to encrypt data
- Customer master key is a logical representation of a master key (real key stored in HSM), the CMK includes metadata, such as:
  - The key ID
  - Creation date
  - Description
  - and Key state
- AWS KMS supports symmetric and asymmetric CMKs
  - Symmetric Key: Use one key
    - AES-256 key
  - Asymmetric Key: Use two keys (eg. public and private key)
    - SSH key

## CLI

```bash
aws kms create-key
# -> Key ID
aws kms create-alias --target-key-id=xxx --alias-name=alias/xxx
echo -n "123456" | openssl base64 | aws kms encrypt --key-id=alias/xxx --plaintext
# -> Ciphertext
aws kms decrypt --ciphertext-blob=xxx --key-id=alias/xxx
aws kms enable-key-roration
```

## Practical notes

* Data must be base64 encoded
* Alias must have `alias/xxx` format

* Automatic key rotation: 
  * Cannot perform on a CMK in a different AWS account
  * When key is rotated, AWS keep previous versions of key, to decrypt data encrypted under old key version. New data are encrypted using new key version. So there is no need to re-encryptˇ [link](https://aws.amazon.com/kms/faqs/)
* Ciphertext created by `encrypt` command is called Data key

