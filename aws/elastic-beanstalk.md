---
title: Elastic Beanstalk notes
code: https://github.com/moonlight8978/aws-cda-preparation/tree/beanstalk
---

- PaaS - Platform as a Service: a platform allowing customers to develop, run, manage applications without building and maintaining infrastructure
  - e.g. Heroku

* Not recommended for "Production" (enterprise, large companies) apps

* Cost nothing to use EB, only the resources it provisions

* Powered by CloudFormation template:

  - ELB
  - Autoscaling groups
  - RDS
  - EC2 instances (preconfigured or custom)
  - CloudWatch, SNS
  - In-place, Blue/Green deployment
  - Rotate passwords
  - Can run dockerized environment

* Can launch either a Web Environment or a Worker Environment

* Web environment

  ![AWS Elastic Beanstalk architecture diagram](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/images/aeb-architecture2.png)

  - The environment will face the Internet
  - 2 types:
    - Single-instance env: desire capacity set to 1, no ELB, use public IP address (EIP)
    - Load balanced env: use ELB, CNAME (URL) will point to ELB
  - A software called Host Manager (HM) will be installed on each instance
    - Deploy app
    - Generate events
    - Monitoring
    - ...

* Worker environment

  ![       AWS Elastic Beanstalk worker tier architecture diagram     ](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/images/aeb-architecture_worker.png)

  - No ELB, no face internet

  - Create SQS queue, install SQS daemon on instances

  - ASG scaling policy to add/remove instances based on queue size

  - Workflow:

    ![       Elastic Beanstalk worker environment Amazon SQS message processing      ](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/images/aeb-messageflow-worker.png)

    - Web environment receive requests
    - Web environment send message to SQS (using SDK)
    - SQS daemon will send HTTP POST request to trigger the worker (run locally in instance)

  - Support periodic tasks

  - Acknowledge: `200 OK` response. Then `DeleteMessage` will be sent to SQS to delete message from the queue.

* Deployment policy:

  - All at once: default
  - Rolling / Rolling with additional batch: split into batches and deploys the new version to one batch at a time
    - If failed -> rolling update to old version
    - Difference:
      - Rolling: Terminate then attach -> capacity reduced
      - Rolling with additional batch: deploy new version first, then attach/terminate new batch/existing batch -> capacity not reduced
  - Immutable: performs an immutable update to launch a full set of new instances running the new version of app in a seperated ASG
    - If failed -> terminate ASG
    - Safest way to deploy for critical applications
  - Blue/green:
    - Deploy 2 environments: Blue (new) and Green (old), when Blue is ready, terminate Green.
    - DNS change

* In-Place vs Blue/Green deployment

  - The context can changes the scope of what it mean
  - Within the scope of EB env
    - In-Place: all EB deployment policies (changes occurred within EB)
    - Blue/Green: We need 2 seperated EB env, database must placed outside. Once env is terminated, all data is lost.

* Configuration file: `.ebextensions/.config`

* Environment manifest: `env.yml`

  - e.g.

    ```yml
    AWSConfigurationTemplateVersion: 1.1.0.0
    EnvironmentName: exapro-prod+
    SolutionStack: Ruby
    EnvironmentLinks:
      "WORKERQUEUE": "worker+"
    OptionSettings:
      aws:elb:loadbalancer:
        CrossZone: true
    ```

  - `+` in name will enable groups

    - e.g. with the environment name `front+` and the group name `dev` => the environment name will be `front-dev`

* Linux Server Configuration

  - Packages: Download & install packages

    ```yml
    packages:
      yum:
        libmemcached: []
        ruby-devel: []
    ```

  - Groups: Create unix group, assign group id

    ```yml
    groups:
      groupAdmin: {}
      groupDev:
        gid: "12"
    ```

  - Users: Create unix user

    ```yml
    users:
      andrew:
        groups:
          - groupAdmin
        uid: 87
        homeDir: "/andrew"
    ```

  - Files: Create files on the ec2 instance (inline or from URL)

    ```yml
    files:
      "/home/ec2-user/application.yml":
        mode: "000755"
        owner: root
        group: root
        content: |
          SECRET: 000destruct0
    ```

  - Execute commends before app is setup

    ```yml
    commands:
      1_project_root:
        command: mkdir /var/www/app
      2_link:
        command: ln -s /var/www/app /app
    ```

  - Services: which services should start/stop when the instance launch

    ```yml
    services:
      sysvinit:
        nginx:
          enabled: true
          ensureRunning: true
    ```

  - Container commands: execute commands that affect the app source code

    ```yml
    container_commands:
      0_collectstatic:
        command: "django-admin.py collectstatic --noinput"
      1_syncdb:
        command: "django-admin.py syncdb --noinput"
        leader_only: true
      2_migrate:
        command: "django-admin.py migrate"
        leader_only: true
    ```

* Custom Image: use custom AMIs instead of AWS preconfigured images => improve provisioning times

![](https://images.viblo.asia/026545c8-b4b4-4aa0-b1e6-45c3eb9169b2.png)

- RDS:

  - Inside EB env: Intended for development env, if EB is terminated the database will be terminated too
  - Outside EB env: Intended for production env

- `Dockerrun.aws.json` is similar to ECS Task Definition, which defines multi container configuration

- Practice notes:

  - Use `eb` CLI to use CodeCommit with EB (eb will zip source code and push to S3 automatically), otherwise use S3 with .zip

    - debug `/var/log/eb-engine.log`, `/var/log/cfn-init.log`

    - deploying app source code is at `/var/app/staging`

    - deployed source code is at `/var/app/current`

    - No environment variable available when SSH to instance

      Use this command to show env available

      ```bash
      /opt/elasticbeanstalk/bin/get-config --output YAML environment
      ```

    - SSL: Load Balancer required

    - Sensitive env:

      - Using `eb` CLI

      ```
      eb setenv VAR_NAME=VAR_VALUE
      ```

      - Using console

  - Roles

    - EC2 instances: use aws-elasticbeanstalk-ec2-role
      - Access S3, DynamoDB, X-Ray, ...
    - EB environment itself: aws-elasticbeanstack-service-role
      - Create ASG, Launch EC2 instance, create DB, ALB, ...
    - Monitoring service-linked role
      - Is a unique type of IAM role that is linked directly to an AWS service
