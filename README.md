<!-- BEGIN_TF_DOCS -->
# Terraform Network-as-Code Cisco NX-OS Module

A Terraform module to configure Cisco NX-OS devices.

## Usage

This module supports an inventory driven approach, where a complete NX-OS configuration or parts of it are either modeled in one or more YAML files or natively using Terraform variables.

## Examples

Configuring an NX-OS system configuration using YAML:

#### `system.nac.yaml`

```yaml
nxos:
  devices:
    - name: Switch1
      url: https://1.2.3.4
      configuration:
        system:
          hostname: Switch1
          mtu: 9216
```

#### `main.tf`

```hcl
module "nxos" {
  source  = "netascode/nac-nxos/nxos"
  version = ">= 0.1.0"

  yaml_files = ["system.nac.yaml"]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.7.0 |
| <a name="requirement_nxos"></a> [nxos](#requirement\_nxos) | = 0.8.0 |
| <a name="requirement_utils"></a> [utils](#requirement\_utils) | = 2.0.0-beta1 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_managed_device_groups"></a> [managed\_device\_groups](#input\_managed\_device\_groups) | List of device group names to be managed. By default all device groups will be managed. | `list(string)` | `[]` | no |
| <a name="input_managed_devices"></a> [managed\_devices](#input\_managed\_devices) | List of device names to be managed. By default all devices will be managed. | `list(string)` | `[]` | no |
| <a name="input_model"></a> [model](#input\_model) | As an alternative to YAML files, a native Terraform data structure can be provided as well. | `map(any)` | `{}` | no |
| <a name="input_save_config"></a> [save\_config](#input\_save\_config) | Write changes to startup-config on all devices. | `bool` | `false` | no |
| <a name="input_write_default_values_file"></a> [write\_default\_values\_file](#input\_write\_default\_values\_file) | Write all default values to a YAML file. Value is a path pointing to the file to be created. | `string` | `""` | no |
| <a name="input_write_model_file"></a> [write\_model\_file](#input\_write\_model\_file) | Write the rendered device model to a single YAML file. Value is a path pointing to the file to be created. | `string` | `""` | no |
| <a name="input_yaml_directories"></a> [yaml\_directories](#input\_yaml\_directories) | List of paths to YAML directories. | `list(string)` | `[]` | no |
| <a name="input_yaml_files"></a> [yaml\_files](#input\_yaml\_files) | List of paths to YAML files. | `list(string)` | `[]` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_values"></a> [default\_values](#output\_default\_values) | All default values. |
| <a name="output_model"></a> [model](#output\_model) | Full model. |
## Resources

| Name | Type |
|------|------|
| [nxos_access_list.access_list](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/access_list) | resource |
| [nxos_bgp.bgp](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/bgp) | resource |
| [nxos_bridge_domain.bridge_domain](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/bridge_domain) | resource |
| [nxos_cli.cli_0](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/cli) | resource |
| [nxos_cli.cli_1](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/cli) | resource |
| [nxos_cli.cli_2](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/cli) | resource |
| [nxos_cli.cli_3](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/cli) | resource |
| [nxos_cli.cli_4](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/cli) | resource |
| [nxos_cli.cli_5](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/cli) | resource |
| [nxos_cli.cli_6](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/cli) | resource |
| [nxos_cli.cli_7](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/cli) | resource |
| [nxos_cli.cli_8](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/cli) | resource |
| [nxos_cli.cli_9](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/cli) | resource |
| [nxos_default_qos.default_qos](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/default_qos) | resource |
| [nxos_dhcp.dhcp](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/dhcp) | resource |
| [nxos_evpn.evpn](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/evpn) | resource |
| [nxos_feature.feature](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/feature) | resource |
| [nxos_hmm.hmm](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/hmm) | resource |
| [nxos_hsrp.hsrp](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/hsrp) | resource |
| [nxos_icmpv4.icmpv4](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/icmpv4) | resource |
| [nxos_ipv4.ipv4](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/ipv4) | resource |
| [nxos_ipv6.ipv6](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/ipv6) | resource |
| [nxos_isis.isis](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/isis) | resource |
| [nxos_keychain.keychain](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/keychain) | resource |
| [nxos_logging.logging](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/logging) | resource |
| [nxos_loopback_interface.loopback_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/loopback_interface) | resource |
| [nxos_ntp.ntp](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/ntp) | resource |
| [nxos_nvo.nvo](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/nvo) | resource |
| [nxos_ospf.ospf](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/ospf) | resource |
| [nxos_ospfv3.ospfv3](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/ospfv3) | resource |
| [nxos_physical_interface.physical_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/physical_interface) | resource |
| [nxos_pim.pim](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/pim) | resource |
| [nxos_port_channel_interface.port_channel_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/port_channel_interface) | resource |
| [nxos_queuing_qos.queuing_qos](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/queuing_qos) | resource |
| [nxos_route_policy.route_policy](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/route_policy) | resource |
| [nxos_save_config.save_config](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/save_config) | resource |
| [nxos_spanning_tree.spanning_tree](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/spanning_tree) | resource |
| [nxos_subinterface.subinterface](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/subinterface) | resource |
| [nxos_svi_interface.svi_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/svi_interface) | resource |
| [nxos_system.system](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/system) | resource |
| [nxos_user_management.user_management](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/user_management) | resource |
| [nxos_vpc.vpc](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/vpc) | resource |
| [nxos_vrf.vrf](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0/docs/resources/vrf) | resource |
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_model"></a> [model](#module\_model) | ./modules/model | n/a |
<!-- END_TF_DOCS -->