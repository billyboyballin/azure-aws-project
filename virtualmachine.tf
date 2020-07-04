#######################################################################
# Azure
#######################################################################

# public IP for azure VM
resource "azurerm_public_ip" "public_ip_vm" {
  name                = "public_ip_vm"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  allocation_method = "Static"
}

resource "azurerm_network_interface" "network_interface_vm" {
  name                = "network_interface_vm"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.AzureAWSPeering_Azure_Subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public_ip_vm.id
  }
}

# azure VM
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  size                = "Standard_F2"
  admin_username      = "ubuntu"

  network_interface_ids = [
    azurerm_network_interface.network_interface_vm.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username   = "ubuntu"
    # IMPORTANT
    # Add here your own public SSH key, so we can access the VM
    public_key = file("/home/ubuntu/.ssh/authorized_keys/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

output "azure_vm_public_ip" {
  value = azurerm_linux_virtual_machine.vm.public_ip_address
}

output "azure_vm_private_ip" {
  value = azurerm_linux_virtual_machine.vm.private_ip_address
}

#######################################################################
# AWS
#######################################################################

# aws security group
resource "aws_security_group" "ssh" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
  from_port = -1
  to_port = -1
  protocol = "icmp"
  cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "security_group_ssh"
  }
}

data "aws_ami" "latest-ubuntu" {
most_recent = true
owners = ["099720109477"] # Canonical

  filter {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }
}

# aws VM
resource "aws_instance" "publicvm" {
  ami           = data.aws_ami.latest-ubuntu.id
  instance_type = "t2.micro"

  vpc_security_group_ids      = [aws_security_group.ssh.id]
  subnet_id                   = aws_subnet.subnet_1.id

  key_name = "awskey"
}

resource "aws_instance" "privatevm" {
  ami           = data.aws_ami.latest-ubuntu.id
  instance_type = "t2.micro"

  vpc_security_group_ids      = [aws_security_group.ssh.id]
  subnet_id                   = aws_subnet.subnet_2.id

  key_name = "awskey"
}

output "aws_vm_private_ip" {
  value = aws_instance.publicvm.private_ip
}
output "aws_vm_public_ip" {
  value = aws_instance.publicvm.public_ip
}
