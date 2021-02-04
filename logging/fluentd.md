---
title: Fluentd
code: https://github.com/moonlight8978/rails-exploration/tree/logging
---



#### Overview

* Basic flow: Input => Filter => Output

  * Input: 

    * How to get log
      * Listen on UDP traffic
      * Tail a system file
    * `parser` can be applied to get right log format

  * Filter: 

    * Apply transformation to event

      * Add custom attribute
      * Parse log file

    * Raw log go through `parser` will become `log event`

      ```txt
      tag:    app.event
      time:   1362020400t
      record: {"host":"192.168.0.1","size":777,"method":"PUT"}
      ```

  * Output: 

    * How to store/forward the log event 
      * Save in elasticsearch
      * Save to file
      * Save to S3
    * Each output has default `formatter` to format log event to appropriate format
      * `out_file` has `out_file` formatter as default which will transform log event into `<time>\t<tag>\t<record>`
      * `single_value` to output single field on `record`, which default is `message`

  * E.g: 

    * Combine `none` parser with `single_value` as output formatter, we will get

      * Raw log: `2021-01-01 GET /test 200 OK`

      * Log event: raw log will be wrapped to `message` key

        ```txt
        tag:    app.event
        time:   1362020400t
        record: {"message":"2021-01-01 GET /test 200 OK"}
        ```

      * Output: Only `message` key on record is exported

        ```txt
        2021-01-01 GET /test 200 OK\n
        ```

        

##### Install on Linux AMI 2

* Installation

	```bash
	# https://docs.fluentd.org/installation/install-by-rpm#amazon-linux
	curl -L https://toolbelt.treasuredata.com/sh/install-amazon2-td-agent4.sh | sh
	```

* Plugins

  ```bash
  sudo td-agent-gem install fluent-plugin-multi-format-parser
  ```


* Configuration file

  ```bash
  sudo vim /etc/td-agent/td-agent.conf
  ```

  ```bash
  td-agent -c /etc/td-agent/td-agent.conf
  ```

* Service configuration file

  ```bash
  sudo vim /usr/lib/systemd/system/td-agent.service
  ```

* Workaround when combine with logrotate

  https://github.com/common-voice/common-voice/pull/848/files
  
  * Add `flush_at_shutdown true` to output plugin buffer
  
  * Stop fluentd to upload current progress, then remove the pos and restart fluentd to tail the log file from the beginning
  
  ```txt
  /root/rails-exploration/log/production.log {
    prerotate
      /bin/systemctl stop td-agent
    endscript
  
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    copytruncate
  
    postrotate
      /bin/rm -f /var/log/td-agent/*.pos
      /bin/systemctl start td-agent
    endscript
  }
  ```
  
  