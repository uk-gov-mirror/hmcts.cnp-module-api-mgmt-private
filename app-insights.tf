module "application_insights" {
  source = "git::https://github.com/hmcts/terraform-module-application-insights?ref=4.x"

  env     = local.environment
  product = var.department
  name    = "${var.department}-api-mgmt"

  resource_group_name = var.virtual_network_resource_group
  application_type    = "other"

  sampling_percentage = var.sampling_percentage

  common_tags = var.common_tags
}

moved {
  from = azurerm_application_insights.apim
  to   = module.application_insights.azurerm_application_insights.this
}
