variable "enable_ct" {
  description = "Determines logging is enabled for Cloud Trail"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name of Cloud Trail"
  type        = string
  default     = "org-cloud-trail"
}

variable "include_global_service_events" {
  description = "Determines if non-regional services like IAM will be logged via Cloud Trail"
  type        = bool
  default     = true
}

variable "ct_tags" {
  description = "Tags for Cloud Trail"
  type        = map(string)
  default     = {}
}

variable "trusted_kms_admin_arns" {
  description = "ARNs of entities that will have administrative access to KMS key associated with Cloud Trail"
  type        = list(string)
}

variable "bucket_name" {
  description = "Name of S3 bucket for Cloud Trail logs"
  type        = string
  default     = "org-cloud-trail-logs"
}

variable "key_prefix" {
  description = "S3 key prefix to put Cloud Trail logs under"
  type        = string
  default     = null
}

variable "cw_log_group_name" {
  description = "Name of Cloud Watch log group name"
  type        = string
  default     = "org-cloud-trail-logs"
}

variable "log_retention_days" {
  description = "Number of days Cloud Watch will retain the logs"
  type        = number
}

