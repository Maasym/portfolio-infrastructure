data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "keyvault"{
  name = "keyvaultspech"
  resource_group_name = azurerm_resource_group.keyvault.name
}

data "azurerm_key_vault_secret" "storage-access-key-1"{
  name = "storage-access-key-1"
  key_vault_id = data.azurerm_key_vault.keyvault.id
}