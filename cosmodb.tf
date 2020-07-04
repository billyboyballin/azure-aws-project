##########################################################################
# Azure cosmodb
##########################################################################

resource "azurerm_cosmosdb_account" "account" {
  name = "mycosmodb"
  location = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  offer_type = "Standard"
  kind = "GlobalDocumentDB"

  ip_range_filter = "104.42.195.92,40.76.54.131,52.176.6.30,52.169.50.45,52.187.184.26,75.75.108.78"

  is_virtual_network_filter_enabled = true

  virtual_network_rule {
    id = azurerm_subnet.AzureAWSPeering_Azure_Subnet.id
  }

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location = "eastus2"
    failover_priority = 0
  }

}

output "cosmodb_id" {
  value = azurerm_cosmosdb_account.account.id
}

output "cosmodb_endpoint" {
  value = azurerm_cosmosdb_account.account.endpoint
}

output "cosmodb_connectionstrings" {
  value = azurerm_cosmosdb_account.account.connection_strings
}



/*
resource "azurerm_cosmosdb_sql_database" "database" {
  name = "testdatabase"
  resource_group_name = azurerm_cosmosdb_account.account.resource_group_name
  account_name = azurerm_cosmosdb_account.account.name
}

resource "azurerm_cosmosdb_sql_container" "container" {
  name = "testcontainer"
  resource_group_name = azurerm_cosmosdb_account.account.resource_group_name
  account_name = azurerm_cosmosdb_account.account.name
  database_name = azurerm_cosmosdb_sql_database.database.name
  partition_key_path = "/PartitionKeyId"
}
104.42.195.92,40.76.54.131,52.176.6.30,52.169.50.45,52.187.184.26
*/
