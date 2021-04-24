resource "aws_config_organization_managed_rule" "this" {
  for_each = { for rule in var.managed_rules: rule.name => rule}

  name            = each.value.name
  rule_identifier = each.value.rule_identifier
}

resource "aws_config_organization_custom_rule" "this" {
	for_each = { for rule in var.custom_rules: rule.name => rule }

  lambda_function_arn = module.lambda[each.value.name].function_arn
  name                = each.value.name
  trigger_types       = each.value.trigger_types

	depends_on = [
    module.lambda
	]
}

module "lambda" {
	for_each = { for rule in var.custom_rules: rule.name => rule }
	source = "github.com/marshall7m/terraform-aws-lambda/modules//function"

	function_name = each.value.function_name
	handler = each.value.handler
	runtime = each.value.runtime
	env_vars = each.value.env_vars

	allowed_to_invoke = [
		{
			principal = "config.amazonaws.com"
		}
	]
	filename = each.value.filename
	image_uri = each.value.image_uri
	s3_bucket = each.value.s3_bucket
	s3_key = each.value.s3_key
}