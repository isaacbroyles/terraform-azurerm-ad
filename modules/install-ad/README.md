# Active Directory Install Script

This folder contains a script for installing Active Directory and its dependencies. You can use this script to create a Active Directory [Azure Managed Image 
](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/build-image-with-packer) that can be deployed in 
[Azure](https://azure.microsoft.com/).

This script has been tested on Windows Server 2016. It has a good chance on working on other versions of Windows Server as long as they have Powershell v5.1.

## Quick start

To install Active Directory, use `git` to clone this repository and run the `ActiveDirectoryConfig.ps1` script:

```
git clone --branch <VERSION> https://github.com/isaacbroyles/terraform-azurerm-ad.git
terraform-azurerm-ad/modules/install-ad/ActiveDirectoryConfig.ps1
```

The `ActiveDirectoryConfig.ps1` script will install Active Directory using [Powershell DSC](https://docs.microsoft.com/en-us/powershell/dsc/overview).

Run the `ActiveDirectoryConfig.ps1` script as part of a [Packer](https://www.packer.io/) template to create a Active Directory [Azure Managed Image](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/build-image-with-packer) (see the [ad-image example](https://github.com/hashicorp/terraform-azurerm-ad/tree/master/examples/ad-image) for sample code). You can then deploy the Azure Image across a Scale Set  (see the [main example](https://github.com/hashicorp/terraform-azurerm-ad/tree/master/MAIN.md) for fully-working sample code).

## How it works

The `ActiveDirectoryConfig.ps1` script does the following:

1. [Install Active Directory binaries and scripts](#install-Active Directory-binaries-and-scripts)

### Install Active Directory binaries and scripts

Install the following:

* `ADDS Install` - Installs Active Directory Domain Services
* `ADDS Tools` - Installs Active Directory tools 

Configures AD:

* Configures a domain controller with the following properties (using environment variables):
  * `SAFEMODEADMINISTRATORUSER` - 
  * `SAFEMODEADMINISTRATORPASSWORD` - Password for the administrator account when the computer is started in Safe Mode.
  * `DOMAINADMIN` - Credentials used to query for domain existence.
  * `DOMAINPASSWORD` - Credentials used to query for domain existence.
    * _Note: These are NOT used during domain creation._
  * `NEWADUSER` - Specifies the Security Account Manager (SAM) account name of the user.
    * To be compatible with older operating systems, create a SAM account name that is 20 characters or less.
    * Once created, the user's SamAccountName cannot be changed.
  * `NEWADUSERPASSWORD` - Password value for the user account.
    * _You must ensure that the password meets the domain's complexity requirements._
