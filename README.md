# aws-certmanager-terraform-module
Terraform module for updating ACM certificates with Let'sEncrypt via Lambda

Lambda function will check ACM certificates, taken first name from {certificate-domains} variable
and in case of non-existence or expiration <= 30 days, request and install new certificate from LetsEncrypt.
Validation is performed with dns-01 check, so permissions to create/update R53 records are mandatory. 

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| certificate-domains | Comma-separated list of records to include in LetsEncrypt request | string | - | yes |
| certificate-email   | Email to be included in LetsEncrypt request | string | - | yes |
| cron-expression     | Cron expression for function triggering | string | `cron(10 02 * * ? *)` | yes |
| default-tags        | Tags to put to Lambda | map | `{}` | no |
| memory-size         | Amount of memory in MB your Lambda Function can use at runtime | string | `128` | yes |
| name                | The name of Lambda Function | string | `lambda-certificate-provisioner` | yes |
| r53-zone-name       | Name of Route53 zone for dns-01 validation | string | - | yes |
| region              | Lambda's region | string | `eu-west-1` | yes |
| role-arn            | role ARN to assume for init process | string | - | yes |
| sg-ids              | IDs of Security Groups to attach to Lambda | list | - | yes |
| slack-channel       | Slack channel for notifications | string | - | yes |
| slack-token         | Slack token for notifications | string | - | yes |
| subnet-ids          | IDs of subnets, in which Lambda relies | list | - | yes |
| timeout             | The amount of time your Lambda Function has to run in seconds | string | `300` | yes |


## Building

Lambda function has only one dependency yet - certbot-dns-route53>=0.29.1.
To build it we have to call `make` from command line within a module folder.
_Note for MacOs users: we are gonna build libs for Linux platform, so will use Docker image with Python3.6 and GCC onboard_
This will put all the necessary libraries to `python_code` folder, which later be picked up by TF module and provided to Lambda


## Executing

Simplest way is to call it as a module, providing all the variables inline, but for production its always better to use tfvars approach

```
module "aws-certmanager-terraform-module-caller" {
  source = "/Users/test/aws-certmanager-terraform-module"

  slack-channel = "slack_channel"
  slack-token = "xoxb-000000000-000000000000-zzzzzzzzzzzzzzzzz"
  certificate-email = "user@domain.com"
  certificate-domains = "jira.domain.com,confluence.domain.com"
  r53-zone-name = "domain.com."
  sg-ids = ["sg-000000000"]
  subnet-ids = ["subnet-000000000"]
  role-arn = "arn:aws:iam::00000000000:role/ExternalAdminRole"
  default-tags= { name = "lambda-certificate-provisioner", region = "eu-west-1" }
}
```