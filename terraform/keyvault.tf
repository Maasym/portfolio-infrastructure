resource "azurerm_resource_group" "keyvault" {
  location = "West Europe"
  name     = "keyvault"
}

resource "azurerm_key_vault" "keyvault" {
  location                   = azurerm_resource_group.keyvault.location
  name                       = "keyvaultspech"
  resource_group_name        = azurerm_resource_group.keyvault.name
  sku_name                   = "standard"
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7

  access_policy {
    object_id = data.azurerm_client_config.current.object_id
    tenant_id = data.azurerm_client_config.current.tenant_id

    secret_permissions      = var.secret_permissions
    key_permissions         = var.key_permissions
  }
}

resource "azurerm_key_vault_access_policy" "aks-access-to-kv" {
  key_vault_id     = data.azurerm_key_vault.keyvault.id
  tenant_id        = data.azurerm_client_config.current.tenant_id
  object_id        = data.azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id

  certificate_permissions = [
    "Get",
  ]

  secret_permissions = [
    "Get",
  ]

  depends_on = [data.azurerm_kubernetes_cluster.aks]
}