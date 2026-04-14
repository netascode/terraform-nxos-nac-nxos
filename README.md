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
| <a name="requirement_nxos"></a> [nxos](#requirement\_nxos) | = 0.9.2 |
| <a name="requirement_utils"></a> [utils](#requirement\_utils) | = 2.0.0-beta2 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_managed_device_groups"></a> [managed\_device\_groups](#input\_managed\_device\_groups) | List of device group names to be managed. By default all device groups will be managed. | `list(string)` | `[]` | no |
| <a name="input_managed_devices"></a> [managed\_devices](#input\_managed\_devices) | List of device names to be managed. By default all devices will be managed. | `list(string)` | `[]` | no |
| <a name="input_model"></a> [model](#input\_model) | As an alternative to YAML files, a native Terraform data structure can be provided as well. | `map(any)` | `{}` | no |
| <a name="input_save_config"></a> [save\_config](#input\_save\_config) | Write changes to startup-config on all devices. | `bool` | `false` | no |
| <a name="input_template_directories"></a> [template\_directories](#input\_template\_directories) | List of paths to directories containing template files. | `list(string)` | `[]` | no |
| <a name="input_template_files"></a> [template\_files](#input\_template\_files) | List of paths to template files. | `list(string)` | `[]` | no |
| <a name="input_write_model_file"></a> [write\_model\_file](#input\_write\_model\_file) | Write the rendered device model to a single YAML file. Value is a path pointing to the file to be created. | `string` | `""` | no |
| <a name="input_yaml_directories"></a> [yaml\_directories](#input\_yaml\_directories) | List of paths to YAML directories. | `list(string)` | `[]` | no |
| <a name="input_yaml_files"></a> [yaml\_files](#input\_yaml\_files) | List of paths to YAML files. | `list(string)` | `[]` | no |
## Outputs

No outputs.
## Resources

| Name | Type |
|------|------|
| [local_sensitive_file.model](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [nxos_access_list.access_list](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/access_list) | resource |
| [nxos_bfd.bfd](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/bfd) | resource |
| [nxos_bgp.bgp](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/bgp) | resource |
| [nxos_bridge_domain.bridge_domain](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/bridge_domain) | resource |
| [nxos_cli.cli_0](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/cli) | resource |
| [nxos_cli.cli_1](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/cli) | resource |
| [nxos_cli.cli_2](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/cli) | resource |
| [nxos_cli.cli_3](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/cli) | resource |
| [nxos_cli.cli_4](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/cli) | resource |
| [nxos_cli.cli_5](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/cli) | resource |
| [nxos_cli.cli_6](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/cli) | resource |
| [nxos_cli.cli_7](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/cli) | resource |
| [nxos_cli.cli_8](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/cli) | resource |
| [nxos_cli.cli_9](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/cli) | resource |
| [nxos_default_qos.default_qos](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/default_qos) | resource |
| [nxos_dhcp.dhcp](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/dhcp) | resource |
| [nxos_evpn.evpn](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/evpn) | resource |
| [nxos_feature.feature](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/feature) | resource |
| [nxos_hmm.hmm](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/hmm) | resource |
| [nxos_hsrp.hsrp](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/hsrp) | resource |
| [nxos_icmpv4.icmpv4](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/icmpv4) | resource |
| [nxos_ipv4.ipv4](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/ipv4) | resource |
| [nxos_ipv6.ipv6](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/ipv6) | resource |
| [nxos_isis.isis](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/isis) | resource |
| [nxos_keychain.keychain](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/keychain) | resource |
| [nxos_logging.logging](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/logging) | resource |
| [nxos_loopback_interface.loopback_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/loopback_interface) | resource |
| [nxos_ntp.ntp](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/ntp) | resource |
| [nxos_nvo.nvo](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/nvo) | resource |
| [nxos_ospf.ospf](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/ospf) | resource |
| [nxos_ospfv3.ospfv3](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/ospfv3) | resource |
| [nxos_physical_interface.physical_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/physical_interface) | resource |
| [nxos_pim.pim](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/pim) | resource |
| [nxos_port_channel_interface.port_channel_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/port_channel_interface) | resource |
| [nxos_queuing_qos.queuing_qos](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/queuing_qos) | resource |
| [nxos_route_policy.route_policy](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/route_policy) | resource |
| [nxos_save_config.save_config](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/save_config) | resource |
| [nxos_snmp.snmp](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/snmp) | resource |
| [nxos_spanning_tree.spanning_tree](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/spanning_tree) | resource |
| [nxos_subinterface.subinterface](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/subinterface) | resource |
| [nxos_svi_interface.svi_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/svi_interface) | resource |
| [nxos_system.system](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/system) | resource |
| [nxos_user_management.user_management](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/user_management) | resource |
| [nxos_vpc.vpc](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/vpc) | resource |
| [nxos_vrf.vrf](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.9.2/docs/resources/vrf) | resource |
## Modules

No modules.
<!-- END_TF_DOCS -->