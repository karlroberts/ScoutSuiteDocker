# README
#### run the ScoutSuite Cloud infrastructure audit tool in a docker container to avoid spilling python all over your OS

CloudSuite now supports AWS, Azure and Google cloud. nice.

Read the docs in the [ScoutSuite Wiki](https://github.com/nccgroup/ScoutSuite/wiki) or their [Github README](https://github.com/nccgroup/ScoutSuite/blob/master/README.md)

But to save time here are some notes on how I use it.

We use aws-vault to assume Roles in AWS that can run a security audit any which ever account we have permissions for. This prevents the need to pass around AWS credentials to perform this crucial task.


## Setup the Docker image

    ./build-docker.sh

## Run
    
    # aws-vault exec <profile from ~/.aws/config> -- ./run.sh
    aws-vault exec my-aws-profile1 --assume-role-ttl=1h -- ./run.sh aws --no-browser --force --timestamp --report-dir /output/scoutsuite-report --max-workers 3 --regions ap-southeast-1 ap-southeast-2 us-west-1 us-west-2 eu-west-1 sa-east-1 --exceptions ~/path/to/my_exceptions.json

Note that I change the default assume-role-ttl (time to live) from 15 minutes to 1 hour, these audits take about 30 mins so don't want acces revoked half way through.

Note that for `aws` I explicitly pass in the regions that I know I have infrastructure in (default is all) this speed up the audit but also prevents authenticatino errors that you'll see when running it. Some AWS regions are not enabled by default and if you try them your credentials fail, you can turn themi on in your AWS console or via CLI but only turn on what you need.

Note that the `max-workers` is `3` this is because AWS throttles CLI queries and the default `10` always got me throttled and spewed out warnings

### aws config
You should have set up your AWS config such that you have specified a region
and have a profile that can assume a role that has Admin read only permisions

so an example `~/.aws/config` may look like

    [default]
    region=ap-southeast-2
    output=json

    # I have credentials for this user in account 012345678910
    # it uses MFA but has no permisions other than it can assume the 
    # SECURITY_AUDIT role in another account 10987654321
    # SECURITY_AUDIT role has policy `SecurityAudit` or `ReadOnlyAccess` on it.
    [my-iam-user]
    region=ap-southeast-2
    mfa_serial=arn:aws:iam::012345678910:mfa/my.username

    # This profile uses the credentials for `my-iam-user` but assumes a Role in an account
    # that has the AWS managed policy `ReadOnlyAccess` or `SecurityAudit` attached to it
    [profile securityAudit]
    region=ap-souteast-2
    source_profile=my-iam-user
    mfa_serial=arn:aws:iam::012345678910:mfa/my.username
    role_arn=arn:aws:iam::10987654321:role/SECURITY_AUDIT

### credentials
Download an Access Key for the user my.username from the AWS console -> Security Credentials -> Access key panel for the user my.username

Add the credentials to aws-vault

    aws-vault add my-iam-user
    # then follow the prompt

