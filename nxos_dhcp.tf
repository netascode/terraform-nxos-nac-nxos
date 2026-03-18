locals {
  dhcp_relay_interfaces = flatten([
    for device in local.devices : concat(
      [for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        device       = device.name
        interface_id = "eth${int.id}"
        dhcp_relay   = int.dhcp_relay
      } if try(int.dhcp_relay, null) != null],
      [for int in try(local.device_config[device.name].interfaces.vlans, []) : {
        device       = device.name
        interface_id = "vlan${int.id}"
        dhcp_relay   = int.dhcp_relay
      } if try(int.dhcp_relay, null) != null],
      [for int in try(local.device_config[device.name].interfaces.loopbacks, []) : {
        device       = device.name
        interface_id = "lo${int.id}"
        dhcp_relay   = int.dhcp_relay
      } if try(int.dhcp_relay, null) != null],
      [for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        device       = device.name
        interface_id = "po${int.id}"
        dhcp_relay   = int.dhcp_relay
      } if try(int.dhcp_relay, null) != null],
    )
  ])
}

resource "nxos_dhcp" "dhcp" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].dhcp, null) != null ||
    length([for int in try(local.device_config[device.name].interfaces.ethernets, []) : int if try(int.dhcp_relay, null) != null]) > 0 ||
    length([for int in try(local.device_config[device.name].interfaces.vlans, []) : int if try(int.dhcp_relay, null) != null]) > 0 ||
    length([for int in try(local.device_config[device.name].interfaces.loopbacks, []) : int if try(int.dhcp_relay, null) != null]) > 0 ||
  length([for int in try(local.device_config[device.name].interfaces.port_channels, []) : int if try(int.dhcp_relay, null) != null]) > 0 }
  device                                      = each.key
  admin_state                                 = "enabled"
  relay_information_option                    = try(local.device_config[each.key].dhcp.relay_information_option, local.defaults.nxos.devices.configuration.dhcp.relay_information_option, null)
  relay_information_option_trust              = try(local.device_config[each.key].dhcp.relay_information_option_trust, local.defaults.nxos.devices.configuration.dhcp.relay_information_option_trust, null)
  relay_information_option_vpn                = try(local.device_config[each.key].dhcp.relay_information_option_vpn, local.defaults.nxos.devices.configuration.dhcp.relay_information_option_vpn, null)
  relay_information_trust_all                 = try(local.device_config[each.key].dhcp.relay_information_trust_all, local.defaults.nxos.devices.configuration.dhcp.relay_information_trust_all, null)
  relay_information_option_server_id_override = try(local.device_config[each.key].dhcp.relay_information_option_server_id_override, local.defaults.nxos.devices.configuration.dhcp.relay_information_option_server_id_override, null) == null ? null : (try(local.device_config[each.key].dhcp.relay_information_option_server_id_override, local.defaults.nxos.devices.configuration.dhcp.relay_information_option_server_id_override) ? 1 : 0)
  relay_sub_option_circuit_id_customized      = try(local.device_config[each.key].dhcp.relay_sub_option_circuit_id_customized, local.defaults.nxos.devices.configuration.dhcp.relay_sub_option_circuit_id_customized, null)
  relay_sub_option_circuit_id_format_string   = try(local.device_config[each.key].dhcp.relay_sub_option_circuit_id_format_string, local.defaults.nxos.devices.configuration.dhcp.relay_sub_option_circuit_id_format_string, null)
  relay_sub_option_type_cisco                 = try(local.device_config[each.key].dhcp.relay_sub_option_type_cisco, local.defaults.nxos.devices.configuration.dhcp.relay_sub_option_type_cisco, null)
  relay_sub_option_format_non_tlv             = try(local.device_config[each.key].dhcp.relay_sub_option_format_non_tlv, local.defaults.nxos.devices.configuration.dhcp.relay_sub_option_format_non_tlv, null)
  smart_relay_global                          = try(local.device_config[each.key].dhcp.smart_relay_global, local.defaults.nxos.devices.configuration.dhcp.smart_relay_global, null)
  v4_relay                                    = try(local.device_config[each.key].dhcp.ip_relay, local.defaults.nxos.devices.configuration.dhcp.ip_relay, null)
  v6_relay                                    = try(local.device_config[each.key].dhcp.ipv6_relay, local.defaults.nxos.devices.configuration.dhcp.ipv6_relay, null)
  relay_v4_over_v6                            = try(local.device_config[each.key].dhcp.relay_v4_over_v6, local.defaults.nxos.devices.configuration.dhcp.relay_v4_over_v6, null)
  relay_v6_iapd_route_add                     = try(local.device_config[each.key].dhcp.relay_v6_iapd_route_add, local.defaults.nxos.devices.configuration.dhcp.relay_v6_iapd_route_add, null)
  relay_dai                                   = try(local.device_config[each.key].dhcp.arp_inspection_relay, local.defaults.nxos.devices.configuration.dhcp.arp_inspection_relay, null)
  ipv6_relay_information_option_vpn           = try(local.device_config[each.key].dhcp.ipv6_relay_information_option_vpn, local.defaults.nxos.devices.configuration.dhcp.ipv6_relay_information_option_vpn, null)
  ipv6_relay_option_type_cisco                = try(local.device_config[each.key].dhcp.ipv6_relay_option_type_cisco, local.defaults.nxos.devices.configuration.dhcp.ipv6_relay_option_type_cisco, null)
  ipv6_relay_option79                         = try(local.device_config[each.key].dhcp.ipv6_relay_option79, local.defaults.nxos.devices.configuration.dhcp.ipv6_relay_option79, null)
  v6_smart_relay_global                       = try(local.device_config[each.key].dhcp.ipv6_smart_relay_global, local.defaults.nxos.devices.configuration.dhcp.ipv6_smart_relay_global, null)
  packet_strict_validation                    = try(local.device_config[each.key].dhcp.packet_strict_validation, local.defaults.nxos.devices.configuration.dhcp.packet_strict_validation, null)
  snooping                                    = try(local.device_config[each.key].dhcp.snooping, local.defaults.nxos.devices.configuration.dhcp.snooping, null)
  snooping_information_option                 = try(local.device_config[each.key].dhcp.snooping_information_option, local.defaults.nxos.devices.configuration.dhcp.snooping_information_option, null)
  snooping_verify_mac_address                 = try(local.device_config[each.key].dhcp.snooping_verify_mac_address, local.defaults.nxos.devices.configuration.dhcp.snooping_verify_mac_address, null)
  snooping_sub_option_format_non_tlv          = try(local.device_config[each.key].dhcp.snooping_sub_option_format_non_tlv, local.defaults.nxos.devices.configuration.dhcp.snooping_sub_option_format_non_tlv, null)
  snoop_sub_option_circuit_id_format_string   = try(local.device_config[each.key].dhcp.snooping_sub_option_circuit_id_format_string, local.defaults.nxos.devices.configuration.dhcp.snooping_sub_option_circuit_id_format_string, null)
  dai_log_buffer_entries                      = try(local.device_config[each.key].dhcp.arp_inspection_log_buffer_entries, local.defaults.nxos.devices.configuration.dhcp.arp_inspection_log_buffer_entries, null)
  dai_validate_destination                    = try(local.device_config[each.key].dhcp.arp_inspection_validate_destination, local.defaults.nxos.devices.configuration.dhcp.arp_inspection_validate_destination, null)
  dai_validate_ip                             = try(local.device_config[each.key].dhcp.arp_inspection_validate_ip, local.defaults.nxos.devices.configuration.dhcp.arp_inspection_validate_ip, null)
  dai_validate_source                         = try(local.device_config[each.key].dhcp.arp_inspection_validate_source, local.defaults.nxos.devices.configuration.dhcp.arp_inspection_validate_source, null)
  relay_interfaces = { for item in local.dhcp_relay_interfaces : item.interface_id => {
    information_trusted = try(item.dhcp_relay.information_trusted, local.defaults.nxos.devices.configuration.interfaces.ethernets.dhcp_relay.information_trusted, null)
    smart_relay         = try(item.dhcp_relay.smart_relay, local.defaults.nxos.devices.configuration.interfaces.ethernets.dhcp_relay.smart_relay, null)
    subnet_broadcast    = try(item.dhcp_relay.subnet_broadcast, local.defaults.nxos.devices.configuration.interfaces.ethernets.dhcp_relay.subnet_broadcast, null)
    options             = try(item.dhcp_relay.options, local.defaults.nxos.devices.configuration.interfaces.ethernets.dhcp_relay.options, null)
    subnet_selection    = try(item.dhcp_relay.relay_source_subnet, local.defaults.nxos.devices.configuration.interfaces.ethernets.dhcp_relay.relay_source_subnet, null)
    v6_smart_relay      = try(item.dhcp_relay.ipv6_smart_relay, local.defaults.nxos.devices.configuration.interfaces.ethernets.dhcp_relay.ipv6_smart_relay, null)
    addresses = { for addr in try(item.dhcp_relay.addresses, []) : "${try(addr.vrf, "!unspecified")};${addr.address}" => {
      counter = try(addr.counter, local.defaults.nxos.devices.configuration.interfaces.ethernets.dhcp_relay.addresses.counter, null)
    } }
  } if item.device == each.key }

  depends_on = [
    nxos_feature.feature,
    nxos_loopback_interface.loopback_interface,
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
    nxos_svi_interface.svi_interface,
    nxos_vrf.vrf,
  ]
}
