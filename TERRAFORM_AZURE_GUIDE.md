# 🧠 Terraform Azure Infrastructure Guide
## Memory-Based Learning for Azure VM Deployment

---

## 📚 The Big Picture: Resource Dependencies

```
┌─────────────────────────────────────────────────────────────────────┐
│  1. RESOURCE GROUP (The Container - holds everything)              │
│  ├── 2. STORAGE ACCOUNT (Data storage)                             │
│  ├── 3. KEY VAULT (Secrets storage)                                │
│  │   └── KEY VAULT SECRET (VM password)                            │
│  ├── 4. VIRTUAL NETWORK (Your private network)                     │
│  │   └── 5. SUBNET (Network segment)                               │
│  ├── 6. PUBLIC IP (Internet-facing address)                        │
│  ├── 7. NETWORK INTERFACE (Connects VM to network)                 │
│  │   └── Links: Subnet + Public IP                                 │
│  └── 8. VIRTUAL MACHINE (The actual server)                        │
│       └── Links: NIC + Key Vault Secret                            │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Memory Techniques

### 1. Resource Group - **NL** (Name, Location)
Think: "**N**ew **L**ocation" - Every resource group needs a name and location

```hcl
resource "azurerm_resource_group" "app_grp" {
  name     = "app-grp"        # N - Name
  location = "East US"        # L - Location
}
```

### 2. Storage Account - **NLRTA** (Name, Location, RG, Tier, Replication)
Think: "**N**ever **L**eave **R**ed **T**apes **A**lone"

```hcl
resource "azurerm_storage_account" "storage" {
  name                     = "appgrpstorage2026"  # N - Name (globally unique!)
  location                 = azurerm_resource_group.app_grp.location  # L
  resource_group_name      = azurerm_resource_group.app_grp.name      # R
  account_tier             = "Standard"           # T - Tier
  account_replication_type = "LRS"                # A - replicAtion
}
```

### 3. Virtual Network - **NLRA** (Name, Location, RG, Address space)
Think: "**N**etwork **L**ives in **R**egion with **A**ddresses"

```hcl
resource "azurerm_virtual_network" "vnet" {
  name                = "app-grp-vnet"       # N - Name
  location            = ...location          # L - Location
  resource_group_name = ...name              # R - Resource Group
  address_space       = ["10.0.0.0/16"]      # A - Address space (65,536 IPs)
}
```

### 4. Subnet - **NRVA** (Name, RG, Vnet, Address prefixes)
Think: "**N**etwork **R**equires **V**net **A**ddress"

```hcl
resource "azurerm_subnet" "subnet" {
  name                 = "app-grp-subnet"    # N - Name
  resource_group_name  = ...name             # R - Resource Group
  virtual_network_name = ...vnet.name        # V - VNet name
  address_prefixes     = ["10.0.1.0/24"]     # A - Address (256 IPs)
}
```

### 5. Public IP - **NLRA** (Name, Location, RG, Allocation)
Think: "**N**eed **L**ocation, **R**esource group, **A**llocation method"

```hcl
resource "azurerm_public_ip" "public_ip" {
  name                = "app-grp-public-ip"  # N - Name
  location            = ...location          # L - Location
  resource_group_name = ...name              # R - Resource Group
  allocation_method   = "Static"             # A - Allocation (Static for Standard SKU)
}
```

### 6. Network Interface - **NLRIP** (Name, Location, RG, IP config)
Think: "**N**IC **L**inks **R**esources with **IP**"

```hcl
resource "azurerm_network_interface" "nic" {
  name                = "app-grp-nic"        # N - Name
  location            = ...location          # L - Location
  resource_group_name = ...name              # R - Resource Group
  
  ip_configuration {                         # IP - IP Configuration
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}
```

### 7. Key Vault - **NLRTSA** (Name, Location, RG, Tenant, SKU, Access)
Think: "**N**ever **L**eave **R**eal **T**reasures **S**tored **A**lone"

```hcl
resource "azurerm_key_vault" "vault" {
  name                = "appgrpvault2026"    # N - Name (globally unique!)
  location            = ...location          # L - Location
  resource_group_name = ...name              # R - Resource Group
  tenant_id           = data...tenant_id     # T - Tenant ID
  sku_name            = "standard"           # S - SKU

  access_policy {                            # A - Access Policy
    tenant_id          = ...
    object_id          = ...
    secret_permissions = ["Get", "List", "Set", "Delete", "Purge"]
  }
}
```

### 8. Linux VM - **NLRSN-DAOS** 
Think: "**N**ew **L**inux **R**equires **S**ize, **N**IC - **D**isable password? **A**dmin, **O**S disk, **S**ource image"

```hcl
resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "app-grp-vm"     # N - Name
  location                        = ...location      # L - Location
  resource_group_name             = ...name          # R - Resource Group
  size                            = "Standard_D2s_v3"# S - Size
  network_interface_ids           = [nic.id]         # N - NIC

  disable_password_authentication = false            # D - Disable password auth
  admin_username                  = "azureuser"      # A - Admin username
  admin_password                  = ...              # A - Admin password

  os_disk {                                          # O - OS Disk
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {                           # S - Source image
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  admin_ssh_key {                                    # SSH Key (optional)
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
}
```

---

## 🔢 IP Address Math Trick

**Formula: 32 - prefix = power of 2 = number of IPs**

| CIDR | Calculation | IPs |
|------|-------------|-----|
| /16  | 32-16=16 → 2^16 | 65,536 |
| /24  | 32-24=8 → 2^8  | 256 |
| /28  | 32-28=4 → 2^4  | 16 |
| /32  | 32-32=0 → 2^0  | 1 |

---

## 🛠️ Commands Used

### Terraform Commands

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `terraform init` | Initialize Terraform, download providers | First time or after adding providers |
| `terraform plan` | Preview changes (dry run) | Before applying to see what will change |
| `terraform apply` | Create/update resources | When ready to build infrastructure |
| `terraform apply -auto-approve` | Apply without confirmation | When confident (use carefully!) |
| `terraform destroy` | Delete all resources | Cleanup when done |
| `terraform force-unlock <ID>` | Remove stale state lock | When previous operation crashed |

### Azure CLI Commands

| Command | Purpose |
|---------|---------|
| `az login` | Authenticate to Azure |
| `az account show` | Show current subscription |
| `az vm show -g <RG> -n <VM> --show-details --query publicIps -o tsv` | Get VM public IP |

### SSH Commands

| Command | Purpose |
|---------|---------|
| `ssh -i ~/.ssh/id_rsa azureuser@<IP>` | Connect with SSH key |
| `ssh azureuser@<IP>` | Connect with password |
| `ls -la ~/.ssh/*.pub` | List available SSH public keys |

---

## 🔐 Security Best Practices

1. **Never commit secrets** - Use Key Vault for passwords
2. **Use SSH keys** - More secure than passwords
3. **Set `disable_password_authentication = true`** - For production
4. **Limit access policies** - Minimum required permissions

---

## ⚠️ Common Errors & Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `ssh_key` block not expected | Wrong block name | Use `admin_ssh_key` |
| `disable_password_authentication` must be false | Need password OR SSH key | Add `admin_ssh_key` or set to `false` |
| `PlatformImageNotFound` | Wrong image reference | Use `0001-com-ubuntu-server-jammy` + `22_04-lts` |
| `SkuNotAvailable` | VM size not available in region | Try different size or region |
| `allocation` not recognized | Typo | Use `allocation_method` |
| `Standard SKU requires Static` | Dynamic with Standard | Use `allocation_method = "Static"` |
| State lock error | Previous terraform still running | `terraform force-unlock <ID>` |

---

## 📁 Final Infrastructure Created

| Resource Type | Name | Details |
|---------------|------|---------|
| Resource Group | app-grp | East US |
| Storage Account | appgrpstorage2026 | Standard LRS |
| Virtual Network | app-grp-vnet | 10.0.0.0/16 |
| Subnet | app-grp-subnet | 10.0.1.0/24 |
| Public IP | app-grp-public-ip | Static |
| Network Interface | app-grp-nic | Links subnet + public IP |
| Key Vault | appgrpvault2026 | Stores VM password |
| Key Vault Secret | vm-admin-password | P@ssw0rd1234! |
| Linux VM | app-grp-vm | Ubuntu 22.04, D2s_v3 |

---

## 🎓 Key Takeaways

1. **Order matters** - Terraform handles dependencies automatically via references
2. **References link resources** - `azurerm_resource_group.app_grp.name`
3. **Globally unique names** - Storage accounts and Key Vaults need unique names
4. **State file is critical** - Terraform tracks what it created in `terraform.tfstate`
5. **Plan before apply** - Always review what will change

---

## 🚀 Quick Start Template

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "YOUR-SUBSCRIPTION-ID"
}

# Start building resources here...
```

---

*Created: February 11, 2026*
*Learning method: Step-by-step with memory techniques*
