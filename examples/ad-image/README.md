# ad  AMI

This folder shows an example of how to use the [install-ad sub-module](https://github.com/isaacbroyles/terraform-azurerm-ad/tree/master/modules/install-ad) from this Module with [Packer](https://www.packer.io/) to create an 
[Azure Managed Image](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/build-image-with-packer) that has ad installed on top of Windows Server 2016.

For more info on AD installation and configuration, check out the [install-ad](https://github.com/isaacbroyles/terraform-azurerm-ad/tree/master/modules/install-ad) documentation.

## Quick start

To build the AD Azure Image:

1. `git clone` this repo to your computer.
1. Install [Packer](https://www.packer.io/).
1. Configure your Azure credentials by setting the `ARM_SUBSCRIPTION_ID`, `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET` and `ARM_TENANT_ID` environment variables.
1. Update the `variables` section of the `ad.json` Packer template to specify the Azure region.

1. Run `packer build ad.json`.

