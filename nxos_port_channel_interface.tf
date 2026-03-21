locals {
  interfaces_port_channels = flatten([
    for device in local.devices : [
      for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        key                                     = format("%s/%s", device.name, int.id)
        device                                  = device.name
        id                                      = int.id
        type                                    = "po"
        vrf                                     = try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.port_channels.vrf, "default")
        ospf_process_name                       = try(int.ospf.process, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.process, null)
        ospf_advertise_secondaries              = try(int.ospf.advertise_secondaries, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.advertise_secondaries, false)
        ospf_area                               = try(int.ospf.area, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.area, null)
        ospf_bfd                                = try(int.ospf.bfd, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.bfd, null)
        ospf_cost                               = try(int.ospf.cost, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.cost, null)
        ospf_dead_interval                      = try(int.ospf.dead_interval, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.dead_interval, null)
        ospf_hello_interval                     = try(int.ospf.hello_interval, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.hello_interval, null)
        ospf_network_type                       = try(int.ospf.network_type, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.network_type, null)
        ospf_passive                            = try(int.ospf.passive, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.passive, null)
        ospf_priority                           = try(int.ospf.priority, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.priority, null)
        ospf_authentication_key                 = try(int.ospf.authentication_key, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.authentication_key, null)
        ospf_authentication_key_id              = try(int.ospf.authentication_key_id, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.authentication_key_id, null)
        ospf_authentication_key_secure_mode     = try(int.ospf.authentication_key_secure_mode, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.authentication_key_secure_mode, false)
        ospf_authentication_keychain            = try(int.ospf.authentication_key_chain, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.authentication_key_chain, null)
        ospf_authentication_md5_key             = try(int.ospf.authentication_md5_key, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.authentication_md5_key, null)
        ospf_authentication_md5_key_secure_mode = try(int.ospf.authentication_md5_key_secure_mode, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.authentication_md5_key_secure_mode, false)
        ospf_authentication_type                = try(int.ospf.authentication_type, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.authentication_type, null)
        ospf_advertise_subnet                   = try(int.ospf.advertise_subnet, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.advertise_subnet, false)
        ospf_mtu_ignore                         = try(int.ospf.mtu_ignore, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.mtu_ignore, false)
        ospf_node_flag                          = try(int.ospf.node_flag, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.node_flag, null)
        ospf_retransmit_interval                = try(int.ospf.retransmit_interval, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.retransmit_interval, null)
        ospf_transmit_delay                     = try(int.ospf.transmit_delay, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.transmit_delay, null)
        ospfv3_process                          = try(int.ospfv3.process, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospfv3.process, null)
        ospfv3_advertise_secondaries            = try(int.ospfv3.advertise_secondaries, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospfv3.advertise_secondaries, null)
        ospfv3_area                             = try(int.ospfv3.area, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospfv3.area, null)
        ospfv3_bfd                              = try(int.ospfv3.bfd, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospfv3.bfd, null)
        ospfv3_cost                             = try(int.ospfv3.cost, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospfv3.cost, null)
        ospfv3_dead_interval                    = try(int.ospfv3.dead_interval, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospfv3.dead_interval, null)
        ospfv3_hello_interval                   = try(int.ospfv3.hello_interval, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospfv3.hello_interval, null)
        ospfv3_network_type                     = try(int.ospfv3.network, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospfv3.network, null)
        ospfv3_passive_interface                = try(int.ospfv3.passive_interface, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospfv3.passive_interface, null)
        ospfv3_priority                         = try(int.ospfv3.priority, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospfv3.priority, null)
        ospfv3_instance_id                      = try(int.ospfv3.instance_id, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospfv3.instance_id, null)
        ospfv3_mtu_ignore                       = try(int.ospfv3.mtu_ignore, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospfv3.mtu_ignore, null)
        ospfv3_retransmit_interval              = try(int.ospfv3.retransmit_interval, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospfv3.retransmit_interval, null)
        ospfv3_transmit_delay                   = try(int.ospfv3.transmit_delay, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospfv3.transmit_delay, null)
        pim_bfd                                 = try(int.pim.bfd, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.bfd, null)
        pim_dr_priority                         = try(int.pim.dr_priority, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.dr_priority, null)
        pim_passive                             = try(int.pim.passive, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.passive, null)
        pim_sparse_mode                         = try(int.pim.sparse_mode, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.sparse_mode, null)
        isis_instance_name                      = try(int.isis.instance_name, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.instance_name, null)
        isis_circuit_type                       = try(int.isis.circuit_type, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.circuit_type, null)
        isis_ipv4                               = try(int.isis.ipv4, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.ipv4, null)
        isis_ipv6                               = try(int.isis.ipv6, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.ipv6, null)
        isis_network_type_p2p                   = try(int.isis.network_type_p2p, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.network_type_p2p, null)
        isis_passive                            = try(int.isis.passive, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.passive, null)
        isis_metric_l1                          = try(int.isis.metric_level_1, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.metric_level_1, null)
        isis_metric_l2                          = try(int.isis.metric_level_2, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.metric_level_2, null)
        isis_ipv6_metric_l1                     = try(int.isis.ipv6_metric_level_1, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.ipv6_metric_level_1, null)
        isis_ipv6_metric_l2                     = try(int.isis.ipv6_metric_level_2, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.ipv6_metric_level_2, null)
        isis_priority_l1                        = try(int.isis.priority_level_1, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.priority_level_1, null)
        isis_priority_l2                        = try(int.isis.priority_level_2, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.priority_level_2, null)
        isis_hello_interval                     = try(int.isis.hello_interval, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.hello_interval, null)
        isis_hello_interval_l1                  = try(int.isis.hello_interval_level_1, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.hello_interval_level_1, null)
        isis_hello_interval_l2                  = try(int.isis.hello_interval_level_2, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.hello_interval_level_2, null)
        isis_hello_multiplier                   = try(int.isis.hello_multiplier, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.hello_multiplier, null)
        isis_hello_multiplier_l1                = try(int.isis.hello_multiplier_level_1, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.hello_multiplier_level_1, null)
        isis_hello_multiplier_l2                = try(int.isis.hello_multiplier_level_2, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.hello_multiplier_level_2, null)
        isis_hello_padding                      = try(int.isis.hello_padding, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.hello_padding, null)
        isis_authentication_check               = try(int.isis.authentication_check, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.authentication_check, null)
        isis_authentication_check_level_1       = try(int.isis.authentication_check_level_1, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.authentication_check_level_1, null)
        isis_authentication_check_level_2       = try(int.isis.authentication_check_level_2, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.authentication_check_level_2, null)
        isis_authentication_key_chain           = try(int.isis.authentication_key_chain, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.authentication_key_chain, null)
        isis_authentication_key_chain_level_1   = try(int.isis.authentication_key_chain_level_1, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.authentication_key_chain_level_1, null)
        isis_authentication_key_chain_level_2   = try(int.isis.authentication_key_chain_level_2, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.authentication_key_chain_level_2, null)
        isis_authentication_type                = try(int.isis.authentication_type, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.authentication_type, null)
        isis_authentication_type_level_1        = try(int.isis.authentication_type_level_1, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.authentication_type_level_1, null)
        isis_authentication_type_level_2        = try(int.isis.authentication_type_level_2, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.authentication_type_level_2, null)
        isis_mtu_check                          = try(int.isis.mtu_check, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.mtu_check, null)
        isis_mtu_check_l1                       = try(int.isis.mtu_check_level_1, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.mtu_check_level_1, null)
        isis_mtu_check_l2                       = try(int.isis.mtu_check_level_2, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.mtu_check_level_2, null)
        isis_ipv4_bfd                           = try(int.isis.ipv4_bfd, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.ipv4_bfd, null)
        isis_ipv6_bfd                           = try(int.isis.ipv6_bfd, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.ipv6_bfd, null)
        isis_csnp_interval_l1                   = try(int.isis.csnp_interval_level_1, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.csnp_interval_level_1, null)
        isis_csnp_interval_l2                   = try(int.isis.csnp_interval_level_2, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.csnp_interval_level_2, null)
        isis_lsp_refresh_interval               = try(int.isis.lsp_refresh_interval, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.lsp_refresh_interval, null)
        isis_retransmit_interval                = try(int.isis.retransmit_interval, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.retransmit_interval, null)
        isis_retransmit_throttle_interval       = try(int.isis.retransmit_throttle_interval, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.retransmit_throttle_interval, null)
        isis_mesh_group_id                      = try(int.isis.mesh_group_id, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.mesh_group_id, null)
        isis_mesh_group_blocked                 = try(int.isis.mesh_group_blocked, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.mesh_group_blocked, null)
        isis_n_flag_clear                       = try(int.isis.n_flag_clear, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.n_flag_clear, null)
        isis_suppressed_state                   = try(int.isis.suppressed_state, local.defaults.nxos.devices.configuration.interfaces.port_channels.isis.suppressed_state, null)
      }
    ]
  ])
}

resource "nxos_port_channel_interface" "port_channel_interface" {
  for_each = { for device in local.devices : device.name => device
  if length(try(local.device_config[device.name].interfaces.port_channels, [])) > 0 }
  device = each.key
  port_channel_interfaces = { for int in try(local.device_config[each.key].interfaces.port_channels, []) : "po${int.id}" => {
    channel_group_mode    = try([for eth in try(local.device_config[each.key].interfaces.ethernets, []) : try(eth.channel_group_mode, local.defaults.nxos.devices.configuration.interfaces.ethernets.channel_group_mode, null) if try(eth.channel_group, null) == int.id][0], null)
    minimum_links         = try(int.lacp_min_links, local.defaults.nxos.devices.configuration.interfaces.port_channels.lacp_min_links, null)
    maximum_links         = try(int.lacp_max_bundle, local.defaults.nxos.devices.configuration.interfaces.port_channels.lacp_max_bundle, null)
    suspend_individual    = try(int.lacp_suspend_individual, local.defaults.nxos.devices.configuration.interfaces.port_channels.lacp_suspend_individual, null) != null ? (try(int.lacp_suspend_individual, local.defaults.nxos.devices.configuration.interfaces.port_channels.lacp_suspend_individual) ? "enable" : "disable") : null
    access_vlan           = !try(int.switchport, local.defaults.nxos.devices.configuration.interfaces.port_channels.switchport, true) ? "unknown" : "vlan-${try(int.switchport_access_vlan, local.defaults.nxos.devices.configuration.interfaces.port_channels.switchport_access_vlan, 1)}"
    admin_state           = try(int.shutdown, local.defaults.nxos.devices.configuration.interfaces.port_channels.shutdown, false) ? "down" : "up"
    auto_negotiation      = try(int.negotiate_auto, local.defaults.nxos.devices.configuration.interfaces.port_channels.negotiate_auto, null)
    bandwidth             = try(int.bandwidth, local.defaults.nxos.devices.configuration.interfaces.port_channels.bandwidth, null)
    delay                 = try(int.delay, local.defaults.nxos.devices.configuration.interfaces.port_channels.delay, null)
    description           = try(int.description, local.defaults.nxos.devices.configuration.interfaces.port_channels.description, null)
    duplex                = try(int.duplex, local.defaults.nxos.devices.configuration.interfaces.port_channels.duplex, null)
    layer                 = !try(int.switchport, local.defaults.nxos.devices.configuration.interfaces.port_channels.switchport, true) ? "Layer3" : "Layer2"
    link_logging          = try(int.logging_event_port_link_status, local.defaults.nxos.devices.configuration.interfaces.port_channels.logging_event_port_link_status, null) != null ? (try(int.logging_event_port_link_status, local.defaults.nxos.devices.configuration.interfaces.port_channels.logging_event_port_link_status) ? "enable" : "disable") : null
    medium                = try(int.medium, local.defaults.nxos.devices.configuration.interfaces.port_channels.medium, null)
    mode                  = try(local.switchport_mode_map[try(int.switchport_mode, local.defaults.nxos.devices.configuration.interfaces.port_channels.switchport_mode)], try(int.switchport_mode, local.defaults.nxos.devices.configuration.interfaces.port_channels.switchport_mode, null))
    mtu                   = try(int.mtu, local.defaults.nxos.devices.configuration.interfaces.port_channels.mtu, null)
    native_vlan           = !try(int.switchport, local.defaults.nxos.devices.configuration.interfaces.port_channels.switchport, true) ? "unknown" : "vlan-${try(int.switchport_trunk_native_vlan, local.defaults.nxos.devices.configuration.interfaces.port_channels.switchport_trunk_native_vlan, 1)}"
    speed                 = try(int.speed, local.defaults.nxos.devices.configuration.interfaces.port_channels.speed, null)
    trunk_vlans           = !try(int.switchport, local.defaults.nxos.devices.configuration.interfaces.port_channels.switchport, true) ? "1-4094" : try(int.switchport_trunk_allowed_vlans, local.defaults.nxos.devices.configuration.interfaces.port_channels.switchport_trunk_allowed_vlans, null)
    dot1q_ethertype       = try(int.dot1q_ethertype, local.defaults.nxos.devices.configuration.interfaces.port_channels.dot1q_ethertype, null)
    graceful_convergence  = try(int.lacp_graceful_convergence, local.defaults.nxos.devices.configuration.interfaces.port_channels.lacp_graceful_convergence, null) != null ? (try(int.lacp_graceful_convergence, local.defaults.nxos.devices.configuration.interfaces.port_channels.lacp_graceful_convergence) ? "enable" : "disable") : null
    hash_distribution     = try(int.port_channel_hash_distribution, local.defaults.nxos.devices.configuration.interfaces.port_channels.port_channel_hash_distribution, null)
    itu_channel           = try(int.itu_channel, local.defaults.nxos.devices.configuration.interfaces.port_channels.itu_channel, null)
    lacp_delay_mode       = try(int.lacp_mode_delay, local.defaults.nxos.devices.configuration.interfaces.port_channels.lacp_mode_delay, null) != null ? (try(int.lacp_mode_delay, local.defaults.nxos.devices.configuration.interfaces.port_channels.lacp_mode_delay) ? "enable" : "disable") : null
    lacp_vpc_convergence  = try(int.lacp_vpc_convergence, local.defaults.nxos.devices.configuration.interfaces.port_channels.lacp_vpc_convergence, null) != null ? (try(int.lacp_vpc_convergence, local.defaults.nxos.devices.configuration.interfaces.port_channels.lacp_vpc_convergence) ? "enable" : "disable") : null
    link_debounce_down    = try(int.link_debounce_time, local.defaults.nxos.devices.configuration.interfaces.port_channels.link_debounce_time, null)
    load_defer            = try(int.port_channel_load_defer, local.defaults.nxos.devices.configuration.interfaces.port_channels.port_channel_load_defer, null) != null ? (try(int.port_channel_load_defer, local.defaults.nxos.devices.configuration.interfaces.port_channels.port_channel_load_defer) ? "enable" : "disable") : null
    mdix                  = try(int.mdix, local.defaults.nxos.devices.configuration.interfaces.port_channels.mdix, null)
    router_mac            = try(int.mac_address, local.defaults.nxos.devices.configuration.interfaces.port_channels.mac_address, null)
    snmp_trap_state       = try(int.snmp_trap_link_status, local.defaults.nxos.devices.configuration.interfaces.port_channels.snmp_trap_link_status, null) != null ? (try(int.snmp_trap_link_status, local.defaults.nxos.devices.configuration.interfaces.port_channels.snmp_trap_link_status) ? "enable" : "disable") : null
    squelch               = try(int.squelch, local.defaults.nxos.devices.configuration.interfaces.port_channels.squelch, null) != null ? (try(int.squelch, local.defaults.nxos.devices.configuration.interfaces.port_channels.squelch) ? "enable" : "disable") : null
    transmission_mode     = try(int.switchport_transparent_mode, local.defaults.nxos.devices.configuration.interfaces.port_channels.switchport_transparent_mode, null)
    trunk_logging         = try(int.logging_event_port_trunk_status, local.defaults.nxos.devices.configuration.interfaces.port_channels.logging_event_port_trunk_status, null) != null ? (try(int.logging_event_port_trunk_status, local.defaults.nxos.devices.configuration.interfaces.port_channels.logging_event_port_trunk_status) ? "enable" : "disable") : null
    user_configured_flags = "admin_layer,admin_mtu,admin_state"
    vrf_dn                = !try(int.switchport, local.defaults.nxos.devices.configuration.interfaces.port_channels.switchport, true) ? "sys/inst-${try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.port_channels.vrf, "default")}" : null
    members = { for eth in try(local.device_config[each.key].interfaces.ethernets, []) : "sys/intf/phys-[eth${eth.id}]" => {
      force = try(eth.channel_group_force, local.defaults.nxos.devices.configuration.interfaces.ethernets.channel_group_force, false)
    } if try(eth.channel_group, null) == int.id }
  } }

  depends_on = [
    nxos_feature.feature,
    nxos_physical_interface.physical_interface,
    nxos_vrf.vrf,
  ]
}
