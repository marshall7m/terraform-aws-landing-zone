resource "aws_config_organization_managed_rule" "this" {
  for_each = length(var.managed_rules) > 0 ? { for rule in var.managed_rules : rule.name => rule } : {}

  name                        = each.value.name
  rule_identifier             = each.value.rule_identifier
  input_parameters            = jsonencode(each.value.input_parameters)
  description                 = each.value.description
  excluded_accounts           = each.value.excluded_accounts
  maximum_execution_frequency = each.value.maximum_execution_frequency
  depends_on = [
    aws_config_configuration_aggregator.this
  ]
}

resource "aws_config_organization_custom_rule" "this" {
  for_each = { for rule in var.custom_rules : rule.name => rule }

  lambda_function_arn         = module.lambda[each.value.name].function_arn
  name                        = each.value.name
  trigger_types               = each.value.trigger_types
  input_parameters            = jsonencode(each.value.input_parameters)
  description                 = each.value.description
  maximum_execution_frequency = each.value.maximum_execution_frequency
  excluded_accounts           = each.value.excluded_accounts
  depends_on = [
    module.lambda
  ]
}

module "lambda" {
  for_each = { for rule in var.custom_rules : rule.name => rule }
  source   = "github.com/marshall7m/terraform-aws-lambda?ref=v0.1.0"

  function_name = each.value.function_name
  handler       = each.value.handler
  runtime       = each.value.runtime
  env_vars      = each.value.env_vars

  allowed_to_invoke = [
    {
      principal = "config.amazonaws.com"
    }
  ]
  filename  = each.value.filename
  image_uri = each.value.image_uri
  s3_bucket = each.value.s3_bucket
  s3_key    = each.value.s3_key
}

resource "aws_config_conformance_pack" "this" {
  for_each = { for pack in var.conformance_packs : pack.name => pack }
  name     = each.value.name

  dynamic "input_parameter" {
    for_each = { for param in each.value.input_parameters : param.name => param }
    content {
      parameter_name  = input_parameter.value.name
      parameter_value = input_parameter.value.value
    }
  }

  template_body = each.value.template_body

  depends_on = [aws_config_configuration_recorder.this]
}