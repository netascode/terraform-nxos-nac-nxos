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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.3.0 |
| <a name="requirement_nxos"></a> [nxos](#requirement\_nxos) | = 0.8.0-beta7 |
| <a name="requirement_utils"></a> [utils](#requirement\_utils) | >= 0.2.6 |
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
| [nxos_bgp.bgp](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/bgp) | resource |
| [nxos_bgp_address_family.bgp_address_family](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/bgp_address_family) | resource |
| [nxos_bgp_advertised_prefix.bgp_advertised_prefix](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/bgp_advertised_prefix) | resource |
| [nxos_bgp_graceful_restart.bgp_graceful_restart](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/bgp_graceful_restart) | resource |
| [nxos_bgp_instance.bgp_instance](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/bgp_instance) | resource |
| [nxos_bgp_peer.bgp_peer](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/bgp_peer) | resource |
| [nxos_bgp_peer_address_family.bgpPeerAf](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/bgp_peer_address_family) | resource |
| [nxos_bgp_peer_address_family_route_control.bgp_peer_address_family_route_control](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/bgp_peer_address_family_route_control) | resource |
| [nxos_bgp_peer_template.bgp_peer_template](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/bgp_peer_template) | resource |
| [nxos_bgp_peer_template_address_family.bgp_peer_template_address_family](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/bgp_peer_template_address_family) | resource |
| [nxos_bgp_route_control.bgp_route_control](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/bgp_route_control) | resource |
| [nxos_bgp_route_redistribution.bgp_route_redistribution](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/bgp_route_redistribution) | resource |
| [nxos_bgp_vrf.bgp_vrf](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/bgp_vrf) | resource |
| [nxos_bridge_domain.bridge_domain](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/bridge_domain) | resource |
| [nxos_evpn.evpn](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/evpn) | resource |
| [nxos_evpn_vni.evpn_vni](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/evpn_vni) | resource |
| [nxos_evpn_vni_route_target.evpn_vni_route_target](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/evpn_vni_route_target) | resource |
| [nxos_evpn_vni_route_target_direction.evpn_vni_route_target_direction](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/evpn_vni_route_target_direction) | resource |
| [nxos_feature.feature](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/feature) | resource |
| [nxos_hmm.hmm](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/hmm) | resource |
| [nxos_icmpv4.icmpv4](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/icmpv4) | resource |
| [nxos_ipv4_interface.ethernet_ipv4_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/ipv4_interface) | resource |
| [nxos_ipv4_interface.loopback_ipv4_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/ipv4_interface) | resource |
| [nxos_ipv4_interface.svi_ipv4_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/ipv4_interface) | resource |
| [nxos_ipv4_interface_address.ethernet_ipv4_interface_address](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/ipv4_interface_address) | resource |
| [nxos_ipv4_interface_address.ethernet_ipv4_secondary_interface_address](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/ipv4_interface_address) | resource |
| [nxos_ipv4_interface_address.loopback_ipv4_interface_address](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/ipv4_interface_address) | resource |
| [nxos_ipv4_interface_address.loopback_ipv4_secondary_interface_address](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/ipv4_interface_address) | resource |
| [nxos_ipv4_interface_address.svi_ipv4_interface_address](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/ipv4_interface_address) | resource |
| [nxos_ipv4_interface_address.svi_ipv4_secondary_interface_address](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/ipv4_interface_address) | resource |
| [nxos_ipv4_prefix_list_rule.ipv4_prefix_list_rule](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/ipv4_prefix_list_rule) | resource |
| [nxos_ipv4_prefix_list_rule_entry.ipv4_prefix_list_rule_entry](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/ipv4_prefix_list_rule_entry) | resource |
| [nxos_ipv4_vrf.ipv4_vrf](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/ipv4_vrf) | resource |
| [nxos_ipv4_vrf.ipv4_vrf_default](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/ipv4_vrf) | resource |
| [nxos_loopback_interface.loopback_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/loopback_interface) | resource |
| [nxos_nve_interface.nve_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/nve_interface) | resource |
| [nxos_nve_vni.nve_vni](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/nve_vni) | resource |
| [nxos_nve_vni_container.nve_vni_container](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/nve_vni_container) | resource |
| [nxos_nve_vni_ingress_replication.nve_vni_ingress_replication](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/nve_vni_ingress_replication) | resource |
| [nxos_ospf.ospf](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/ospf) | resource |
| [nxos_physical_interface.physical_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/physical_interface) | resource |
| [nxos_pim.pim](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/pim) | resource |
| [nxos_port_channel_interface.port_channel_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/port_channel_interface) | resource |
| [nxos_route_map_rule.route_map_rule](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/route_map_rule) | resource |
| [nxos_route_map_rule_entry.route_map_rule_entry](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/route_map_rule_entry) | resource |
| [nxos_route_map_rule_entry_match_route.route_map_rule_entry_match_route](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/route_map_rule_entry_match_route) | resource |
| [nxos_route_map_rule_entry_match_route_prefix_list.route_map_rule_entry_match_route_prefix_list](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/route_map_rule_entry_match_route_prefix_list) | resource |
| [nxos_route_map_rule_entry_set_regular_community.route_map_rule_entry_set_regular_community](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/route_map_rule_entry_set_regular_community) | resource |
| [nxos_route_map_rule_entry_set_regular_community_item.route_map_rule_entry_set_regular_community_item](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/route_map_rule_entry_set_regular_community_item) | resource |
| [nxos_save_config.save_config](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/save_config) | resource |
| [nxos_svi_interface.svi_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/svi_interface) | resource |
| [nxos_system.system](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/system) | resource |
| [nxos_vrf.vrf](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/vrf) | resource |
| [nxos_vrf_address_family.vrf_address_family](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/vrf_address_family) | resource |
| [nxos_vrf_route_target.vrf_route_target](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/vrf_route_target) | resource |
| [nxos_vrf_route_target_address_family.vrf_route_target_address_family](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/vrf_route_target_address_family) | resource |
| [nxos_vrf_route_target_direction.vrf_route_target_direction](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/vrf_route_target_direction) | resource |
| [nxos_vrf_routing.vrf_routing](https://registry.terraform.io/providers/CiscoDevNet/nxos/0.8.0-beta7/docs/resources/vrf_routing) | resource |
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_model"></a> [model](#module\_model) | ./modules/model | n/a |
<!-- END_TF_DOCS -->