locals {
  switchport_mode_map = {
    "trunk-secondary"   = "trunk_secondary"
    "trunk-promiscuous" = "trunk_promiscuous"
  }
  interfaces_ethernets = flatten([
    for device in local.devices : [
      for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        key                                     = format("%s/%s", device.name, int.id)
        device                                  = device.name
        id                                      = int.id
        type                                    = "eth"
        switchport_access_vlan                  = try(int.switchport.access_vlan, 1)
        admin_state                             = try(int.shutdown, false)
        negotiate_auto                          = try(int.negotiate_auto, null)
        bandwidth                               = try(int.bandwidth, null)
        delay                                   = try(int.delay, null)
        description                             = try(int.description, null)
        duplex                                  = try(int.duplex, null)
        fec                                     = try(int.fec, null)
        switchport                              = !try(int.switchport.enabled, true)
        link_debounce_time                      = try(int.link_debounce_time, null)
        link_debounce_link_up                   = try(int.link_debounce_link_up, null)
        logging_event_port_link_status          = try(int.logging_event_port_link_status, null)
        medium                                  = try(int.medium, null)
        mode                                    = try(local.switchport_mode_map[try(int.switchport.mode)], try(int.switchport.mode, null))
        mtu                                     = try(int.mtu, null)
        switchport_trunk_native_vlan            = try(int.switchport.trunk_native_vlan, 1)
        speed                                   = try(int.speed, null)
        speed_group                             = try(int.speed_group, null)
        switchport_trunk_allowed_vlans          = try(provider::utils::normalize_vlans(try(int.switchport.trunk_allowed_vlans), "string-nxos"), null)
        uni_directional_ethernet                = try(int.uni_directional_ethernet, null)
        vrf                                     = try(int.vrf, "default")
        ip_unnumbered                           = try(int.ip.unnumbered, null)
        ip_verify_unicast_source_reachable_via  = try(int.ip.verify_unicast_source_reachable_via, null)
        ip_address                              = try(int.ip.address, null)
        ospf_process_name                       = try(int.ospf.process, null)
        ospf_advertise_secondaries              = try(int.ospf.advertise_secondaries, false)
        ospf_area                               = try(int.ospf.area, null)
        ospf_bfd                                = try(int.ospf.bfd, null) == null ? null : (try(int.ospf.bfd) ? "enabled" : "disabled")
        ospf_cost                               = try(int.ospf.cost, null)
        ospf_dead_interval                      = try(int.ospf.dead_interval, null)
        ospf_hello_interval                     = try(int.ospf.hello_interval, null)
        ospf_network_type                       = try(int.ospf.network, null)
        ospf_passive                            = try(int.ospf.passive_interface, null) == null ? null : (try(int.ospf.passive_interface) ? "enabled" : "disabled")
        ospf_priority                           = try(int.ospf.priority, null)
        ospf_authentication_key                 = try(int.ospf.authentication_key, null)
        ospf_authentication_key_id              = try(int.ospf.message_digest_key_id, null)
        ospf_authentication_key_secure_mode     = try(int.ospf.authentication_key_secure_mode, false)
        ospf_authentication_keychain            = try(int.ospf.authentication_key_chain, null)
        ospf_authentication_md5_key             = try(int.ospf.message_digest_key, null)
        ospf_authentication_md5_key_secure_mode = try(int.ospf.message_digest_key_secure_mode, false)
        ospf_authentication_type                = try(int.ospf.authentication, null)
        ospf_advertise_subnet                   = try(int.ospf.advertise_subnet, false)
        ospf_mtu_ignore                         = try(int.ospf.mtu_ignore, false)
        ospf_node_flag                          = try(int.ospf.prefix_attribute_n_flag, null)
        ospf_retransmit_interval                = try(int.ospf.retransmit_interval, null)
        ospf_transmit_delay                     = try(int.ospf.transmit_delay, null)
        ospfv3_process                          = try(int.ospfv3.process, null)
        ospfv3_advertise_secondaries            = try(int.ospfv3.advertise_secondaries, null)
        ospfv3_area                             = try(int.ospfv3.area, null)
        ospfv3_bfd                              = try(int.ospfv3.bfd, null) == null ? null : (try(int.ospfv3.bfd) ? "enabled" : "disabled")
        ospfv3_cost                             = try(int.ospfv3.cost, null)
        ospfv3_dead_interval                    = try(int.ospfv3.dead_interval, null)
        ospfv3_hello_interval                   = try(int.ospfv3.hello_interval, null)
        ospfv3_network_type                     = try(int.ospfv3.network, null)
        ospfv3_passive_interface                = try(int.ospfv3.passive_interface, null) == null ? null : (try(int.ospfv3.passive_interface) ? "enabled" : "disabled")
        ospfv3_priority                         = try(int.ospfv3.priority, null)
        ospfv3_instance_id                      = try(int.ospfv3.instance_id, null)
        ospfv3_mtu_ignore                       = try(int.ospfv3.mtu_ignore, null)
        ospfv3_retransmit_interval              = try(int.ospfv3.retransmit_interval, null)
        ospfv3_transmit_delay                   = try(int.ospfv3.transmit_delay, null)
        pim_bfd                                 = try(int.pim.bfd, null)
        pim_dr_priority                         = try(int.pim.dr_priority, null)
        pim_passive                             = try(int.pim.passive, null)
        pim_sparse_mode                         = try(int.pim.sparse_mode, null)
        channel_group                           = try(int.channel_group, null)
        isis_instance_name                      = try(int.isis.instance_name, null)
        isis_circuit_type                       = try(int.isis.circuit_type, null)
        isis_ipv4                               = try(int.isis.ipv4, null)
        isis_ipv6                               = try(int.isis.ipv6, null)
        isis_network_point_to_point             = try(int.isis.network_point_to_point, null)
        isis_passive_interface                  = try(int.isis.passive_interface, null)
        isis_metric_l1                          = try(int.isis.metric_level_1, null)
        isis_metric_l2                          = try(int.isis.metric_level_2, null)
        isis_ipv6_metric_l1                     = try(int.isis.ipv6_metric_level_1, null)
        isis_ipv6_metric_l2                     = try(int.isis.ipv6_metric_level_2, null)
        isis_priority_l1                        = try(int.isis.priority_level_1, null)
        isis_priority_l2                        = try(int.isis.priority_level_2, null)
        isis_hello_interval                     = try(int.isis.hello_interval, null)
        isis_hello_interval_l1                  = try(int.isis.hello_interval_level_1, null)
        isis_hello_interval_l2                  = try(int.isis.hello_interval_level_2, null)
        isis_hello_multiplier                   = try(int.isis.hello_multiplier, null)
        isis_hello_multiplier_l1                = try(int.isis.hello_multiplier_level_1, null)
        isis_hello_multiplier_l2                = try(int.isis.hello_multiplier_level_2, null)
        isis_hello_padding                      = try(int.isis.hello_padding, null)
        isis_authentication_check               = try(int.isis.authentication_check, null)
        isis_authentication_check_level_1       = try(int.isis.authentication_check_level_1, null)
        isis_authentication_check_level_2       = try(int.isis.authentication_check_level_2, null)
        isis_authentication_key_chain           = try(int.isis.authentication_key_chain, null)
        isis_authentication_key_chain_level_1   = try(int.isis.authentication_key_chain_level_1, null)
        isis_authentication_key_chain_level_2   = try(int.isis.authentication_key_chain_level_2, null)
        isis_authentication_type                = try(int.isis.authentication_type, null)
        isis_authentication_type_level_1        = try(int.isis.authentication_type_level_1, null)
        isis_authentication_type_level_2        = try(int.isis.authentication_type_level_2, null)
        isis_mtu_check                          = try(int.isis.mtu_check, null)
        isis_mtu_check_l1                       = try(int.isis.mtu_check_level_1, null)
        isis_mtu_check_l2                       = try(int.isis.mtu_check_level_2, null)
        isis_bfd                                = try(int.isis.bfd, null) == null ? null : (try(int.isis.bfd) ? "enabled" : "disabled")
        isis_ipv6_bfd                           = try(int.isis.ipv6_bfd, null) == null ? null : (try(int.isis.ipv6_bfd) ? "enabled" : "disabled")
        isis_csnp_interval_l1                   = try(int.isis.csnp_interval_level_1, null)
        isis_csnp_interval_l2                   = try(int.isis.csnp_interval_level_2, null)
        isis_lsp_interval                       = try(int.isis.lsp_interval, null)
        isis_retransmit_interval                = try(int.isis.retransmit_interval, null)
        isis_retransmit_throttle_interval       = try(int.isis.retransmit_throttle_interval, null)
        isis_mesh_group                         = try(int.isis.mesh_group, null)
        isis_mesh_group_blocked                 = try(int.isis.mesh_group_blocked, null)
        isis_n_flag_clear                       = try(int.isis.n_flag_clear, null)
        isis_suppress_prefix                    = try(int.isis.suppress_prefix, null)
      }
    ]
  ])
}

resource "nxos_physical_interface" "physical_interface" {
  for_each = { for device in local.devices : device.name => device
  if length(try(local.device_config[device.name].interfaces.ethernets, [])) > 0 }
  device = each.key
  physical_interfaces = { for int in try(local.device_config[each.key].interfaces.ethernets, []) : "eth${int.id}" => {
    fec_mode                           = try(int.fec, null)
    access_vlan                        = try(int.channel_group, null) != null ? null : (!try(int.switchport.enabled, true) ? "unknown" : "vlan-${try(int.switchport.access_vlan, 1)}")
    admin_state                        = try(int.shutdown, false) ? "down" : "up"
    auto_negotiation                   = try(int.negotiate_auto, null)
    bandwidth                          = try(int.bandwidth, null)
    beacon                             = try(int.beacon, null) != null ? (try(int.beacon) ? "on" : "off") : null
    delay                              = try(int.delay, null)
    description                        = try(int.description, null)
    dfe_adaptive_tuning                = try(int.dfe_adaptive_tuning, null) != null ? (try(int.dfe_adaptive_tuning) ? "enable" : "disable") : null
    dfe_tuning_delay                   = try(int.dfe_tuning_delay, null)
    dot1q_ethertype                    = try(int.dot1q_ethertype, null)
    duplex                             = try(int.duplex, null)
    itu_channel                        = try(int.itu_channel, null)
    layer                              = try(int.channel_group, null) != null ? null : (!try(int.switchport.enabled, true) ? "Layer3" : "Layer2")
    link_active_jitter_management      = try(int.link_active_jitter_management, null) != null ? (try(int.link_active_jitter_management) ? "enable" : "disable") : null
    link_debounce_down                 = try(int.link_debounce_time, null)
    link_debounce_up                   = try(int.link_debounce_link_up, null)
    link_flap_error_disable            = try(int.link_flap_err_disable, null) != null ? (try(int.link_flap_err_disable) ? "enable" : "disable") : null
    link_flap_error_max                = try(int.link_flap_err_disable_max, null)
    link_flap_error_seconds            = try(int.link_flap_err_disable_interval, null)
    link_logging                       = try(int.logging_event_port_link_status, null) != null ? (try(int.logging_event_port_link_status) ? "enable" : "disable") : null
    link_loopback                      = try(int.loopback, null) != null ? (try(int.loopback) ? "enable" : "disable") : null
    link_mac_up_timer                  = try(int.link_mac_up_timer, null)
    link_max_bring_up_timer            = try(int.link_max_bring_up_timer, null)
    link_transmit_reset                = try(int.link_transmit_reset, null) != null ? (try(int.link_transmit_reset) ? "enable" : "disable") : null
    mdix                               = try(int.mdix, null)
    media_type                         = try(int.media_type, null)
    medium                             = try(int.medium, null)
    mode                               = try(local.switchport_mode_map[try(int.switchport.mode)], try(int.switchport.mode, null))
    mtu                                = try(int.mtu, null)
    native_vlan                        = try(int.channel_group, null) != null ? null : (!try(int.switchport.enabled, true) ? "unknown" : "vlan-${try(int.switchport.trunk_native_vlan, 1)}")
    packet_timestamp_egress_source_id  = try(int.packet_timestamp_egress_source_id, null)
    packet_timestamp_ingress_source_id = try(int.packet_timestamp_ingress_source_id, null)
    packet_timestamp_state             = try(int.packet_timestamp, null)
    snmp_trap_state                    = try(int.snmp_trap_link_status, null) != null ? (try(int.snmp_trap_link_status) ? "enable" : "disable") : null
    speed                              = try(int.speed, null)
    speed_group                        = try(int.speed_group, null)
    squelch                            = try(int.squelch, null) != null ? (try(int.squelch) ? "enable" : "disable") : null
    transparent_mode                   = try(int.switchport.transparent_mode, null) == null ? null : (try(int.switchport.transparent_mode) ? "trans-port" : "not-a-trans-port")
    trunk_logging                      = try(int.logging_event_port_trunk_status, null) != null ? (try(int.logging_event_port_trunk_status) ? "enable" : "disable") : null
    trunk_vlans                        = try(int.channel_group, null) != null ? null : (!try(int.switchport.enabled, true) ? "1-4094" : try(provider::utils::normalize_vlans(try(int.switchport.trunk_allowed_vlans), "string-nxos"), null))
    uni_directional_ethernet           = try(int.uni_directional_ethernet, null)
    user_configured_flags              = try(int.channel_group, null) != null ? null : "admin_layer,admin_mtu,admin_state"
    voice_port_cos                     = try(int.switchport.voice_cos, null)
    voice_port_trust                   = try(int.switchport.voice_trust, null) != null ? (try(int.switchport.voice_trust) ? "enable" : "disable") : null
    voice_vlan_id                      = try(int.switchport.voice_vlan, null)
    voice_vlan_type                    = try(int.switchport.voice_vlan_type, null)
    vrf_dn                             = try(int.channel_group, null) != null ? null : (!try(int.switchport.enabled, true) ? "sys/inst-${try(int.vrf, "default")}" : null)
  } }

  depends_on = [
    nxos_vrf.vrf,
  ]
}
