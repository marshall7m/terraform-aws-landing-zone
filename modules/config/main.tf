resource "aws_config_config_rule" "this" {
  for_each         = { for rule in var.rules : rule.name => rule }
  name             = each.value.name
  description      = each.value.description
  input_parameters = each.value.input_parameters

  source {
    owner             = each.value.source
    source_identifier = each.value.source_identifier
  }

  maximum_execution_frequency = try(each.value.maximum_execution_frequency, var.maximum_execution_frequency)
  tags                        = each.value.tags

  depends_on = [aws_config_configuration_recorder.this]
}

resource "aws_config_configuration_recorder_status" "this" {
  count = var.enable_cfg_recorder ? 1 : 0

  name       = var.cfg_name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.this]
}

resource "aws_config_delivery_channel" "this" {
  count = var.enable_cfg_recorder ? 1 : 0

  name           = var.cfg_name
  s3_bucket_name = var.cfg_logs_bucket
  s3_key_prefix  = var.cfg_logs_prefix
  # sns_topic_arn  = var.cfg_sns_topic_arn

  snapshot_delivery_properties {
    delivery_frequency = var.cfg_delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.this]
}

resource "aws_iam_service_linked_role" "config" {
  aws_service_name = "config.amazonaws.com"
}

resource "aws_config_configuration_recorder" "this" {
  count = var.enable_cfg_recorder ? 1 : 0

  name     = var.cfg_name
  role_arn = aws_iam_service_linked_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = var.include_global_resource_types
  }
}