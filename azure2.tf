# Azure local network gateway for tunnel 1 to AWS vpn connection 1
resource "azurerm_local_network_gateway" "local_network_gateway_1_tunnel1" {
  name                = "local_network_gateway_1_tunnel1"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  # AWS VPN Connection public IP address
  gateway_address = aws_vpn_connection.vpn_connection_1.tunnel1_address

  address_space = [
    # AWS VPC CIDR
    aws_vpc.vpc.cidr_block
  ]
}
# tunnel 1 to AWS vpn connection 1
resource "azurerm_virtual_network_gateway_connection" "virtual_network_gateway_connection_1_tunnel1" {
  name                = "virtual_network_gateway_connection_1_tunnel1"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.virtual_network_gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.local_network_gateway_1_tunnel1.id

  # AWS VPN Connection secret shared key
  shared_key = aws_vpn_connection.vpn_connection_1.tunnel1_preshared_key
}
# Azure local network gateway for tunnel 2 to AWS vpn connection 1
resource "azurerm_local_network_gateway" "local_network_gateway_1_tunnel2" {
  name                = "local_network_gateway_1_tunnel2"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  gateway_address = aws_vpn_connection.vpn_connection_1.tunnel2_address

  address_space = [
    aws_vpc.vpc.cidr_block
  ]
}
# tunnel 2 to AWS vpn connection 1
resource "azurerm_virtual_network_gateway_connection" "virtual_network_gateway_connection_1_tunnel2" {
  name                = "virtual_network_gateway_connection_1_tunnel2"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.virtual_network_gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.local_network_gateway_1_tunnel2.id

  shared_key = aws_vpn_connection.vpn_connection_1.tunnel2_preshared_key
}
