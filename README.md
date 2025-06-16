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
| <a name="requirement_nxos"></a> [nxos](#requirement\_nxos) | >= 0.5.9 |
| <a name="requirement_utils"></a> [utils](#requirement\_utils) | >= 0.2.6 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_model"></a> [model](#input\_model) | As an alternative to YAML files, a native Terraform data structure can be provided as well. | `map(any)` | `{}` | no |
| <a name="input_save_config"></a> [save\_config](#input\_save\_config) | Write changes to startup-config on all devices. | `bool` | `false` | no |
| <a name="input_write_default_values_file"></a> [write\_default\_values\_file](#input\_write\_default\_values\_file) | Write all default values to a YAML file. Value is a path pointing to the file to be created. | `string` | `""` | no |
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
| [local_sensitive_file.defaults](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [nxos_bgp.bgp](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/bgp) | resource |
| [nxos_bgp_address_family.bgp_address_family](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/bgp_address_family) | resource |
| [nxos_bgp_advertised_prefix.bgp_advertised_prefix](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/bgp_advertised_prefix) | resource |
| [nxos_bgp_graceful_restart.bgp_graceful_restart](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/bgp_graceful_restart) | resource |
| [nxos_bgp_instance.bgp_instance](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/bgp_instance) | resource |
| [nxos_bgp_peer.bgp_peer](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/bgp_peer) | resource |
| [nxos_bgp_peer_address_family.bgpPeerAf](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/bgp_peer_address_family) | resource |
| [nxos_bgp_peer_address_family_route_control.bgp_peer_address_family_route_control](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/bgp_peer_address_family_route_control) | resource |
| [nxos_bgp_peer_template.bgp_peer_template](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/bgp_peer_template) | resource |
| [nxos_bgp_peer_template_address_family.bgp_peer_template_address_family](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/bgp_peer_template_address_family) | resource |
| [nxos_bgp_route_control.bgp_route_control](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/bgp_route_control) | resource |
| [nxos_bgp_route_redistribution.bgp_route_redistribution](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/bgp_route_redistribution) | resource |
| [nxos_bgp_vrf.bgp_vrf](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/bgp_vrf) | resource |
| [nxos_bridge_domain.bridge_domain](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/bridge_domain) | resource |
| [nxos_ethernet.ethernet](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/ethernet) | resource |
| [nxos_evpn.evpn](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/evpn) | resource |
| [nxos_evpn_vni.evpn_vni](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/evpn_vni) | resource |
| [nxos_evpn_vni_route_target.evpn_vni_route_target](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/evpn_vni_route_target) | resource |
| [nxos_evpn_vni_route_target_direction.evpn_vni_route_target_direction](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/evpn_vni_route_target_direction) | resource |
| [nxos_feature_bfd.bfd](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/feature_bfd) | resource |
| [nxos_feature_bgp.bgp](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/feature_bgp) | resource |
| [nxos_feature_dhcp.dhcp](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/feature_dhcp) | resource |
| [nxos_feature_evpn.evpn](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/feature_evpn) | resource |
| [nxos_feature_hmm.fabric_forwarding](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/feature_hmm) | resource |
| [nxos_feature_hsrp.hsrp](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/feature_hsrp) | resource |
| [nxos_feature_interface_vlan.interface_vlan](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/feature_interface_vlan) | resource |
| [nxos_feature_isis.isis](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/feature_isis) | resource |
| [nxos_feature_lacp.lacp](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/feature_lacp) | resource |
| [nxos_feature_lldp.lldp](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/feature_lldp) | resource |
| [nxos_feature_macsec.macsec](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/feature_macsec) | resource |
| [nxos_feature_netflow.netflow](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/feature_netflow) | resource |
| [nxos_feature_nv_overlay.nv_overlay](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/feature_nv_overlay) | resource |
| [nxos_feature_ospf.ospf](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/feature_ospf) | resource |
| [nxos_feature_ospfv3.ospfv3](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/feature_ospfv3) | resource |
| [nxos_feature_pim.pim](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/feature_pim) | resource |
| [nxos_feature_ptp.ptp](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/feature_ptp) | resource |
| [nxos_feature_pvlan.pvlan](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/feature_pvlan) | resource |
| [nxos_feature_ssh.ssh](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/feature_ssh) | resource |
| [nxos_feature_tacacs.tacacs](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/feature_tacacs) | resource |
| [nxos_feature_telnet.telnet](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/feature_telnet) | resource |
| [nxos_feature_udld.udld](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/feature_udld) | resource |
| [nxos_feature_vn_segment.vn_segment](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/feature_vn_segment) | resource |
| [nxos_feature_vpc.vpc](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/feature_vpc) | resource |
| [nxos_hmm.hmm](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/hmm) | resource |
| [nxos_hmm_instance.hmm_instance](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/hmm_instance) | resource |
| [nxos_hmm_interface.hmm_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/hmm_interface) | resource |
| [nxos_ipv4_interface.ethernet_ipv4_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/ipv4_interface) | resource |
| [nxos_ipv4_interface.loopback_ipv4_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/ipv4_interface) | resource |
| [nxos_ipv4_interface.port_channel_ipv4_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/ipv4_interface) | resource |
| [nxos_ipv4_interface.svi_ipv4_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/ipv4_interface) | resource |
| [nxos_ipv4_interface_address.ethernet_ipv4_interface_address](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/ipv4_interface_address) | resource |
| [nxos_ipv4_interface_address.ethernet_ipv4_secondary_interface_address](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/ipv4_interface_address) | resource |
| [nxos_ipv4_interface_address.loopback_ipv4_interface_address](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/ipv4_interface_address) | resource |
| [nxos_ipv4_interface_address.loopback_ipv4_secondary_interface_address](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/ipv4_interface_address) | resource |
| [nxos_ipv4_interface_address.port_channel_ipv4_interface_address](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/ipv4_interface_address) | resource |
| [nxos_ipv4_interface_address.port_channel_ipv4_secondary_interface_address](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/ipv4_interface_address) | resource |
| [nxos_ipv4_interface_address.svi_ipv4_interface_address](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/ipv4_interface_address) | resource |
| [nxos_ipv4_interface_address.svi_ipv4_secondary_interface_address](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/ipv4_interface_address) | resource |
| [nxos_ipv4_prefix_list_rule.ipv4_prefix_list_rule](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/ipv4_prefix_list_rule) | resource |
| [nxos_ipv4_prefix_list_rule_entry.ipv4_prefix_list_rule_entry](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/ipv4_prefix_list_rule_entry) | resource |
| [nxos_ipv4_vrf.ipv4_vrf](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/ipv4_vrf) | resource |
| [nxos_ipv4_vrf.ipv4_vrf_default](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/ipv4_vrf) | resource |
| [nxos_loopback_interface.loopback_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/loopback_interface) | resource |
| [nxos_loopback_interface_vrf.loopback_interface_vrf](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/loopback_interface_vrf) | resource |
| [nxos_nve_interface.nve_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/nve_interface) | resource |
| [nxos_nve_vni.nve_vni](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/nve_vni) | resource |
| [nxos_nve_vni_container.nve_vni_container](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/nve_vni_container) | resource |
| [nxos_nve_vni_ingress_replication.nve_vni_ingress_replication](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/nve_vni_ingress_replication) | resource |
| [nxos_ospf.ospf](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/ospf) | resource |
| [nxos_ospf_area.ospf_area](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/ospf_area) | resource |
| [nxos_ospf_authentication.ospf_authentication](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/ospf_authentication) | resource |
| [nxos_ospf_instance.ospf_instance](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/ospf_instance) | resource |
| [nxos_ospf_interface.ospf_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/ospf_interface) | resource |
| [nxos_ospf_vrf.ospf_vrf](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/ospf_vrf) | resource |
| [nxos_physical_interface.physical_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/physical_interface) | resource |
| [nxos_physical_interface_vrf.physical_interface_vrf](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/physical_interface_vrf) | resource |
| [nxos_pim.pim](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/pim) | resource |
| [nxos_pim_anycast_rp.pim_anycast_rp](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/pim_anycast_rp) | resource |
| [nxos_pim_anycast_rp_peer.pim_anycast_rp_peer](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/pim_anycast_rp_peer) | resource |
| [nxos_pim_instance.pim_instance](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/pim_instance) | resource |
| [nxos_pim_interface.pim_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/pim_interface) | resource |
| [nxos_pim_static_rp.pim_static_rp](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/pim_static_rp) | resource |
| [nxos_pim_static_rp_group_list.pim_static_rp_group_list](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/pim_static_rp_group_list) | resource |
| [nxos_pim_static_rp_policy.pim_static_rp_policy](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/pim_static_rp_policy) | resource |
| [nxos_pim_vrf.pim_vrf](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/pim_vrf) | resource |
| [nxos_port_channel_interface.port_channel_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/port_channel_interface) | resource |
| [nxos_port_channel_interface_member.port_channel_interface_member](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/port_channel_interface_member) | resource |
| [nxos_port_channel_interface_vrf.port_channel_interface_vrf](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/port_channel_interface_vrf) | resource |
| [nxos_rest.service_acceleration](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/rest) | resource |
| [nxos_rest.service_system_hypershield_sas_sas](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/rest) | resource |
| [nxos_rest.service_system_hypershield_sas_svc](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/rest) | resource |
| [nxos_rest.service_system_hypershield_sas_svc_fw_policy](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/rest) | resource |
| [nxos_rest.service_system_hypershield_sas_svc_fw_policy_ip_vrf](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/rest) | resource |
| [nxos_rest.service_system_hypershield_sas_svc_instance](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/rest) | resource |
| [nxos_rest.service_system_hypershield_sas_svc_scontroller](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/rest) | resource |
| [nxos_route_map_rule.route_map_rule](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/route_map_rule) | resource |
| [nxos_route_map_rule_entry.route_map_rule_entry](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/route_map_rule_entry) | resource |
| [nxos_route_map_rule_entry_match_route.route_map_rule_entry_match_route](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/route_map_rule_entry_match_route) | resource |
| [nxos_route_map_rule_entry_match_route_prefix_list.route_map_rule_entry_match_route_prefix_list](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/route_map_rule_entry_match_route_prefix_list) | resource |
| [nxos_route_map_rule_entry_set_regular_community.route_map_rule_entry_set_regular_community](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/route_map_rule_entry_set_regular_community) | resource |
| [nxos_route_map_rule_entry_set_regular_community_item.route_map_rule_entry_set_regular_community_item](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/route_map_rule_entry_set_regular_community_item) | resource |
| [nxos_save_config.save_config](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/save_config) | resource |
| [nxos_svi_interface.svi_interface](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/svi_interface) | resource |
| [nxos_svi_interface_vrf.svi_interface_vrf](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/svi_interface_vrf) | resource |
| [nxos_system.system](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/system) | resource |
| [nxos_vrf.vrf](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf) | resource |
| [nxos_vrf_address_family.vrf_address_family](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_address_family) | resource |
| [nxos_vrf_route_target.vrf_route_target](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_route_target) | resource |
| [nxos_vrf_route_target_address_family.vrf_route_target_address_family](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_route_target_address_family) | resource |
| [nxos_vrf_route_target_direction.vrf_route_target_direction](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_route_target_direction) | resource |
| [nxos_vrf_routing.vrf_routing](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_routing) | resource |
| [terraform_data.validation](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
## Modules

No modules.
<!-- END_TF_DOCS -->