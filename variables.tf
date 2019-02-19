variable "region" {
  description = "Lambda's region"
  type        = "string"
  default     = "eu-west-1"
}

variable "role-arn" {
  description = "role ARN to assume for init process"
  type        = "string"
}

variable "name" {
  description = "The name of Lambda Function"
  type        = "string"
  default     = "lambda-certificate-provisioner"
}

variable "timeout" {
  description = "The amount of time your Lambda Function has to run in seconds"
  type        = "string"
  default     = "300"
}

variable "memory-size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime"
  type        = "string"
  default     = "128"
}

variable "cron-expression" {
  description = "Cron expression for function triggering"
  type        = "string"
  default     = "cron(10 02 * * ? *)"
}

variable "certificate-domains" {
  description = "Comma-separated list of records to include in LetsEncrypt request"
  type        = "string"
}

variable "certificate-email" {
  description = "Email to be included in LetsEncrypt request"
  type        = "string"
}

variable "slack-channel" {
  description = "Slack channel for notifications"
  type        = "string"
}

variable "slack-token" {
  description = "Slack token for notifications"
  type        = "string"
}

variable "r53-zone-name" {
  description = "Name of Route53 zone for dns-01 validation"
  type        = "string"
}

variable "subnet-ids" {
  description = "IDs of subntes, in which Lambda relies"
  type        = "list"
}

variable "sg-ids" {
  description = "IDs of SGs to attach to Lambda"
  type        = "list"
}

variable "default-tags" {
  description = "Tags to put to Lambda"
  type        = "map"
  default     = {}
}
