# Public IP addresses of azure virtual network gateway
data "azurerm_public_ip" "azure_public_ip_1" {
  # That neat name interpolation
  # The end result is _exactly_ the name of Azure's public IP
  name                = "${azurerm_virtual_network_gateway.virtual_network_gateway.name}_public_ip_1"
  resource_group_name = azurerm_resource_group.resource_group.name
}
# AWS customer gateway 1
resource "aws_customer_gateway" "customer_gateway_1" {
  bgp_asn = 65000

  # Using the previously fetched Azure's public IP
  ip_address = data.azurerm_public_ip.azure_public_ip_1.ip_address
  type       = "ipsec.1"

  tags = {
    Name = "AzureAWSPeering_customer_gateway_1"
  }
}
# AWS VPN gateway
resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "AzureAWSPeering_vpn_gateway"
  }
}
# AWS VPN connection 1
# We will use information from this piece to finish the Azure configuration on the next Step
resource "aws_vpn_connection" "vpn_connection_1" {
  vpn_gateway_id      = aws_vpn_gateway.vpn_gateway.id
  customer_gateway_id = aws_customer_gateway.customer_gateway_1.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = {
    Name = "AzureAWSPeering_vpn_connection_1"
  }
}

# AWS VPN connection routes
resource "aws_vpn_connection_route" "vpn_connection_route_1" {
  # Azure's vnet CIDR
  destination_cidr_block = azurerm_virtual_network.vnet.address_space[0]
  vpn_connection_id      = aws_vpn_connection.vpn_connection_1.id
}

# azure route to route table
# The route teaching where to go to get to Azure's CIDR
resource "aws_route" "route_to_azure_1" {
  route_table_id = aws_route_table.public_route_table.id

  # Azure's vnet CIDR
  destination_cidr_block = azurerm_virtual_network.vnet.address_space[0]
  gateway_id             = aws_vpn_gateway.vpn_gateway.id
}

# azure route to route table
# The route teaching where to go to get to Azure's CIDR
resource "aws_route" "route_to_azure_2" {
  route_table_id = aws_route_table.private_route_table.id

  # Azure's vnet CIDR
  destination_cidr_block = azurerm_virtual_network.vnet.address_space[0]
  gateway_id             = aws_vpn_gateway.vpn_gateway.id
}
