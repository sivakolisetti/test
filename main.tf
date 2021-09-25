# Configure the Microsoft Azure Provider
provider "azurerm" {
    # The "feature" block is required for AzureRM provider 2.x. 
    # If you're using version 1.x, the "features" block is not allowed.
    version = "~>2.0"
    features {}

    subscription_id = "5c6a2898-cc07-443c-a2bb-59390ddc5d8a"
    client_id       = "b3fc8925-58da-48d1-9616-7141c652ac00"
    client_secret   = "3I7DpnAFT.tY2zbvUKw.A.D76L574H.zrS"
    tenant_id       = "f4db9925-ea6e-4e0b-87ef-874608d1fb78"
}

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "myterraformgroup" {
    name     = "myResourceGroup"
    location = "eastus"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = azurerm_resource_group.myterraformgroup.name

    tags = {
        environment = "Terraform Demo"
    }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "mySubnet"
    resource_group_name  = azurerm_resource_group.myterraformgroup.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefix       = "10.0.0.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "myPublicIP"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.myterraformgroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.myterraformgroup.name
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Demo"
    }
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    name                      = "myNIC"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.myterraformgroup.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
    }

    tags = {
        environment = "Terraform Demo"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.myterraformnic.id
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.myterraformgroup.name
    }
    
    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.myterraformgroup.name
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create virtual machine
resource "azurerm_windows_virtual_machine" "myterraformvm" {
    name                  = "myVM1"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [azurerm_network_interface.myterraformnic.id]
    size                  = "Standard_B1s"
    

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2016-Datacenter"
        version   = "latest"
    }

    /*source_image_reference {
        publisher = "Canonical"
125
​
126
# Create virtual machine
127
resource "azurerm_windows_virtual_machine" "myterraformvm" {
128
    name                  = "myVM1"
129
    location              = "eastus"
130
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
131
    network_interface_ids = [azurerm_network_interface.myterraformnic.id]
132
    size                  = "Standard_B1s"
133
    
134
​
135
    os_disk {
136
        name              = "myOsDisk"
137
        caching           = "ReadWrite"
138
        storage_account_type = "Premium_LRS"
139
    }
140
​
141
    source_image_reference {
142
        publisher = "MicrosoftWindowsServer"
143
        offer     = "WindowsServer"
144
        sku       = "2016-Datacenter"
145
        version   = "latest"
146
    }
147
​
148
    /*source_image_reference {
149
        publisher = "Canonical"
150
        offer     = "UbuntuServer"
151
        sku       = "16.04.0-LTS"
152
        version   = "latest"
153
    }*/
154
​
155
    computer_name  = "myvm"
156
    admin_username = "azureuser"
157
    admin_password = "siva@0456"
158
        
159
    /*admin_ssh_key {
160
        username       = "azureuser"
161
        public_key     = file("/home/azureuser/.ssh/authorized_keys")
162
    }*/
163
​
164
    boot_diagnostics {
165
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
166
    }
167
​
168
    tags = {
169
        environment = "Terraform Demo"
170
    }
171
}

        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }*/

    computer_name  = "myvm"
    admin_username = "azureuser"
    admin_password = "siva@0456"
        
    /*admin_ssh_key {
        username       = "azureuser"
        public_key     = file("/home/azureuser/.ssh/authorized_keys")
    }*/

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "Terraform Demo"
    }
}
