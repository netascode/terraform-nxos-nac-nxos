locals {
  interfaces_ethernets = flatten([
    for device in local.devices : [
      for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        key                                     = format("%s/%s", device.name, int.id)
        device                                  = device.name
        id                                      = int.id
        type                                    = "eth"
        access_vlan                             = try(int.access_vlan, local.defaults.nxos.devices.configuration.interfaces.ethernets.access_vlan, 1)
        admin_state                             = try(int.admin_state, local.defaults.nxos.devices.configuration.interfaces.ethernets.admin_state, false)
        auto_negotiation                        = try(int.auto_negotiation, local.defaults.nxos.devices.configuration.interfaces.ethernets.auto_negotiation, null)
        bandwidth                               = try(int.bandwidth, local.defaults.nxos.devices.configuration.interfaces.ethernets.bandwidth, null)
        delay                                   = try(int.delay, local.defaults.nxos.devices.configuration.interfaces.ethernets.delay, null)
        description                             = try(int.description, local.defaults.nxos.devices.configuration.interfaces.ethernets.description, null)
        duplex                                  = try(int.duplex, local.defaults.nxos.devices.configuration.interfaces.ethernets.duplex, null)
        fec_mode                                = try(int.fec_mode, local.defaults.nxos.devices.configuration.interfaces.ethernets.fec_mode, null)
        layer3                                  = try(int.layer3, local.defaults.nxos.devices.configuration.interfaces.ethernets.layer3, false)
        link_debounce_down                      = try(int.link_debounce_down, local.defaults.nxos.devices.configuration.interfaces.ethernets.link_debounce_down, null)
        link_debounce_up                        = try(int.link_debounce_up, local.defaults.nxos.devices.configuration.interfaces.ethernets.link_debounce_up, null)
        link_logging                            = try(int.link_logging, local.defaults.nxos.devices.configuration.interfaces.ethernets.link_logging, null)
        medium                                  = try(int.medium, local.defaults.nxos.devices.configuration.interfaces.ethernets.medium, null)
        mode                                    = try(int.mode, local.defaults.nxos.devices.configuration.interfaces.ethernets.mode, null)
        mtu                                     = try(int.mtu, local.defaults.nxos.devices.configuration.interfaces.ethernets.mtu, null)
        native_vlan                             = try(int.native_vlan, local.defaults.nxos.devices.configuration.interfaces.ethernets.native_vlan, 1)
        speed                                   = try(int.speed, local.defaults.nxos.devices.configuration.interfaces.ethernets.speed, null)
        speed_group                             = try(int.speed_group, local.defaults.nxos.devices.configuration.interfaces.ethernets.speed_group, null)
        trunk_vlans                             = try(int.trunk_vlans, local.defaults.nxos.devices.configuration.interfaces.ethernets.trunk_vlans, null)
        uni_directional_ethernet                = try(int.uni_directional_ethernet, local.defaults.nxos.devices.configuration.interfaces.ethernets.uni_directional_ethernet, null)
        vrf                                     = try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.ethernets.vrf, "default")
        ip_unnumbered                           = try(int.ip_unnumbered, local.defaults.nxos.devices.configuration.interfaces.ethernets.ip_unnumbered, null)
        urpf                                    = try(int.urpf, local.defaults.nxos.devices.configuration.interfaces.ethernets.urpf, null)
        ipv4_address                            = try(int.ipv4_address, local.defaults.nxos.devices.configuration.interfaces.ethernets.ipv4_address, null)
        ospf_process_name                       = try(int.ospf.process_name, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.process_name, null)
        ospf_advertise_secondaries              = try(int.ospf.advertise_secondaries, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.advertise_secondaries, false)
        ospf_area                               = try(int.ospf.area, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.area, null)
        ospf_bfd                                = try(int.ospf.bfd, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.bfd, null)
        ospf_cost                               = try(int.ospf.cost, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.cost, null)
        ospf_dead_interval                      = try(int.ospf.dead_interval, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.dead_interval, null)
        ospf_hello_interval                     = try(int.ospf.hello_interval, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.hello_interval, null)
        ospf_network_type                       = try(int.ospf.network_type, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.network_type, null)
        ospf_passive                            = try(int.ospf.passive, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.passive, null)
        ospf_priority                           = try(int.ospf.priority, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.priority, null)
        ospf_authentication_key                 = try(int.ospf.authentication_key, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.authentication_key, null)
        ospf_authentication_key_id              = try(int.ospf.authentication_key_id, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.authentication_key_id, null)
        ospf_authentication_key_secure_mode     = try(int.ospf.authentication_key_secure_mode, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.authentication_key_secure_mode, false)
        ospf_authentication_keychain            = try(int.ospf.authentication_keychain, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.authentication_keychain, null)
        ospf_authentication_md5_key             = try(int.ospf.authentication_md5_key, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.authentication_md5_key, null)
        ospf_authentication_md5_key_secure_mode = try(int.ospf.authentication_md5_key_secure_mode, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.authentication_md5_key_secure_mode, false)
        ospf_authentication_type                = try(int.ospf.authentication_type, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.authentication_type, null)
        ospf_advertise_subnet                   = try(int.ospf.advertise_subnet, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.advertise_subnet, false)
        ospf_mtu_ignore                         = try(int.ospf.mtu_ignore, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.mtu_ignore, false)
        ospf_node_flag                          = try(int.ospf.node_flag, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.node_flag, null)
        ospf_retransmit_interval                = try(int.ospf.retransmit_interval, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.retransmit_interval, null)
        ospf_transmit_delay                     = try(int.ospf.transmit_delay, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.transmit_delay, null)
        pim_admin_state                         = try(int.pim.admin_state, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.admin_state, null)
        pim_bfd                                 = try(int.pim.bfd, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.bfd, null)
        pim_dr_priority                         = try(int.pim.dr_priority, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.dr_priority, null)
        pim_passive                             = try(int.pim.passive, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.passive, null)
        pim_sparse_mode                         = try(int.pim.sparse_mode, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.sparse_mode, null)
        port_channel                            = try(int.port_channel, local.defaults.nxos.devices.configuration.interfaces.ethernets.port_channel, null)
      }
    ]
  ])
}

resource "nxos_physical_interface" "physical_interface" {
  for_each = { for device in local.devices : device.name => device
  if length(try(local.device_config[device.name].interfaces.ethernets, [])) > 0 }
  device = each.key
  physical_interfaces = { for int in try(local.device_config[each.key].interfaces.ethernets, []) : "eth${int.id}" => {
    fec_mode                           = try(int.fec_mode, local.defaults.nxos.devices.configuration.interfaces.ethernets.fec_mode, null)
    access_vlan                        = try(int.layer3, local.defaults.nxos.devices.configuration.interfaces.ethernets.layer3, false) ? "unknown" : "vlan-${try(int.access_vlan, local.defaults.nxos.devices.configuration.interfaces.ethernets.access_vlan, 1)}"
    admin_state                        = try(int.admin_state, local.defaults.nxos.devices.configuration.interfaces.ethernets.admin_state, false) ? "up" : "down"
    auto_negotiation                   = try(int.auto_negotiation, local.defaults.nxos.devices.configuration.interfaces.ethernets.auto_negotiation, null)
    bandwidth                          = try(int.bandwidth, local.defaults.nxos.devices.configuration.interfaces.ethernets.bandwidth, null)
    beacon                             = try(int.beacon, local.defaults.nxos.devices.configuration.interfaces.ethernets.beacon, null) != null ? (try(int.beacon, local.defaults.nxos.devices.configuration.interfaces.ethernets.beacon) ? "on" : "off") : null
    delay                              = try(int.delay, local.defaults.nxos.devices.configuration.interfaces.ethernets.delay, null)
    description                        = try(int.description, local.defaults.nxos.devices.configuration.interfaces.ethernets.description, null)
    dfe_adaptive_tuning                = try(int.dfe_adaptive_tuning, local.defaults.nxos.devices.configuration.interfaces.ethernets.dfe_adaptive_tuning, null) != null ? (try(int.dfe_adaptive_tuning, local.defaults.nxos.devices.configuration.interfaces.ethernets.dfe_adaptive_tuning) ? "enable" : "disable") : null
    dfe_tuning_delay                   = try(int.dfe_tuning_delay, local.defaults.nxos.devices.configuration.interfaces.ethernets.dfe_tuning_delay, null)
    dot1q_ether_type                   = try(int.dot1q_ether_type, local.defaults.nxos.devices.configuration.interfaces.ethernets.dot1q_ether_type, null)
    duplex                             = try(int.duplex, local.defaults.nxos.devices.configuration.interfaces.ethernets.duplex, null)
    equalization_delay                 = try(int.equalization_delay, local.defaults.nxos.devices.configuration.interfaces.ethernets.equalization_delay, null)
    inherit_bandwidth                  = try(int.inherit_bandwidth, local.defaults.nxos.devices.configuration.interfaces.ethernets.inherit_bandwidth, null)
    itu_channel                        = try(int.itu_channel, local.defaults.nxos.devices.configuration.interfaces.ethernets.itu_channel, null)
    layer                              = try(int.layer3, local.defaults.nxos.devices.configuration.interfaces.ethernets.layer3, false) ? "Layer3" : "Layer2"
    link_active_jitter_management      = try(int.link_active_jitter_management, local.defaults.nxos.devices.configuration.interfaces.ethernets.link_active_jitter_management, null) != null ? (try(int.link_active_jitter_management, local.defaults.nxos.devices.configuration.interfaces.ethernets.link_active_jitter_management) ? "enable" : "disable") : null
    link_debounce_down                 = try(int.link_debounce_down, local.defaults.nxos.devices.configuration.interfaces.ethernets.link_debounce_down, null)
    link_debounce_up                   = try(int.link_debounce_up, local.defaults.nxos.devices.configuration.interfaces.ethernets.link_debounce_up, null)
    link_flap_error_disable            = try(int.link_flap_error_disable, local.defaults.nxos.devices.configuration.interfaces.ethernets.link_flap_error_disable, null) != null ? (try(int.link_flap_error_disable, local.defaults.nxos.devices.configuration.interfaces.ethernets.link_flap_error_disable) ? "enable" : "disable") : null
    link_flap_error_max                = try(int.link_flap_error_max, local.defaults.nxos.devices.configuration.interfaces.ethernets.link_flap_error_max, null)
    link_flap_error_seconds            = try(int.link_flap_error_seconds, local.defaults.nxos.devices.configuration.interfaces.ethernets.link_flap_error_seconds, null)
    link_logging                       = try(int.link_logging, local.defaults.nxos.devices.configuration.interfaces.ethernets.link_logging, null) != null ? (try(int.link_logging, local.defaults.nxos.devices.configuration.interfaces.ethernets.link_logging) ? "enable" : "disable") : null
    link_loopback                      = try(int.link_loopback, local.defaults.nxos.devices.configuration.interfaces.ethernets.link_loopback, null) != null ? (try(int.link_loopback, local.defaults.nxos.devices.configuration.interfaces.ethernets.link_loopback) ? "enable" : "disable") : null
    link_mac_up_timer                  = try(int.link_mac_up_timer, local.defaults.nxos.devices.configuration.interfaces.ethernets.link_mac_up_timer, null)
    link_max_bring_up_timer            = try(int.link_max_bring_up_timer, local.defaults.nxos.devices.configuration.interfaces.ethernets.link_max_bring_up_timer, null)
    link_transmit_reset                = try(int.link_transmit_reset, local.defaults.nxos.devices.configuration.interfaces.ethernets.link_transmit_reset, null) != null ? (try(int.link_transmit_reset, local.defaults.nxos.devices.configuration.interfaces.ethernets.link_transmit_reset) ? "enable" : "disable") : null
    mdix                               = try(int.mdix, local.defaults.nxos.devices.configuration.interfaces.ethernets.mdix, null)
    media_type                         = try(int.media_type, local.defaults.nxos.devices.configuration.interfaces.ethernets.media_type, null)
    medium                             = try(int.medium, local.defaults.nxos.devices.configuration.interfaces.ethernets.medium, null)
    mode                               = try(int.mode, local.defaults.nxos.devices.configuration.interfaces.ethernets.mode, null)
    mtu                                = try(int.mtu, local.defaults.nxos.devices.configuration.interfaces.ethernets.mtu, null)
    native_vlan                        = try(int.layer3, local.defaults.nxos.devices.configuration.interfaces.ethernets.layer3, false) ? "unknown" : "vlan-${try(int.native_vlan, local.defaults.nxos.devices.configuration.interfaces.ethernets.native_vlan, 1)}"
    optics_loopback                    = try(int.optics_loopback, local.defaults.nxos.devices.configuration.interfaces.ethernets.optics_loopback, null)
    packet_timestamp_egress_source_id  = try(int.packet_timestamp_egress_source_id, local.defaults.nxos.devices.configuration.interfaces.ethernets.packet_timestamp_egress_source_id, null)
    packet_timestamp_ingress_source_id = try(int.packet_timestamp_ingress_source_id, local.defaults.nxos.devices.configuration.interfaces.ethernets.packet_timestamp_ingress_source_id, null)
    packet_timestamp_state             = try(int.packet_timestamp_state, local.defaults.nxos.devices.configuration.interfaces.ethernets.packet_timestamp_state, null)
    port_type                          = try(int.port_type, local.defaults.nxos.devices.configuration.interfaces.ethernets.port_type, null)
    snmp_trap_state                    = try(int.snmp_trap_link_status, local.defaults.nxos.devices.configuration.interfaces.ethernets.snmp_trap_link_status, null) != null ? (try(int.snmp_trap_link_status, local.defaults.nxos.devices.configuration.interfaces.ethernets.snmp_trap_link_status) ? "enable" : "disable") : null
    span_mode                          = try(int.span_mode, local.defaults.nxos.devices.configuration.interfaces.ethernets.span_mode, null)
    speed                              = try(int.speed, local.defaults.nxos.devices.configuration.interfaces.ethernets.speed, null)
    speed_group                        = try(int.speed_group, local.defaults.nxos.devices.configuration.interfaces.ethernets.speed_group, null)
    squelch                            = try(int.squelch, local.defaults.nxos.devices.configuration.interfaces.ethernets.squelch, null) != null ? (try(int.squelch, local.defaults.nxos.devices.configuration.interfaces.ethernets.squelch) ? "enable" : "disable") : null
    transparent_mode                   = try(int.transparent_mode, local.defaults.nxos.devices.configuration.interfaces.ethernets.transparent_mode, null)
    trunk_logging                      = try(int.trunk_logging, local.defaults.nxos.devices.configuration.interfaces.ethernets.trunk_logging, null) != null ? (try(int.trunk_logging, local.defaults.nxos.devices.configuration.interfaces.ethernets.trunk_logging) ? "enable" : "disable") : null
    trunk_vlans                        = try(int.layer3, local.defaults.nxos.devices.configuration.interfaces.ethernets.layer3, false) ? "1-4094" : try(int.trunk_vlans, local.defaults.nxos.devices.configuration.interfaces.ethernets.trunk_vlans, null)
    uni_directional_ethernet           = try(int.uni_directional_ethernet, local.defaults.nxos.devices.configuration.interfaces.ethernets.uni_directional_ethernet, null)
    user_configured_flags              = "admin_layer,admin_mtu,admin_state"
    voice_port_cos                     = try(int.voice_port_cos, local.defaults.nxos.devices.configuration.interfaces.ethernets.voice_port_cos, null)
    voice_port_trust                   = try(int.voice_port_trust, local.defaults.nxos.devices.configuration.interfaces.ethernets.voice_port_trust, null) != null ? (try(int.voice_port_trust, local.defaults.nxos.devices.configuration.interfaces.ethernets.voice_port_trust) ? "enable" : "disable") : null
    voice_vlan_id                      = try(int.voice_vlan, local.defaults.nxos.devices.configuration.interfaces.ethernets.voice_vlan, null)
    voice_vlan_type                    = try(int.voice_vlan_type, local.defaults.nxos.devices.configuration.interfaces.ethernets.voice_vlan_type, null)
    vrf_dn                             = try(int.layer3, local.defaults.nxos.devices.configuration.interfaces.ethernets.layer3, false) ? "sys/inst-${try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.ethernets.vrf, "default")}" : null
  } }
}


locals {
  interfaces_port_channels = flatten([
    for device in local.devices : [
      for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        key                                     = format("%s/%s", device.name, int.id)
        device                                  = device.name
        id                                      = int.id
        type                                    = "po"
        vrf                                     = try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.port_channels.vrf, "default")
        ospf_process_name                       = try(int.ospf.process_name, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.process_name, null)
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
        ospf_authentication_keychain            = try(int.ospf.authentication_keychain, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.authentication_keychain, null)
        ospf_authentication_md5_key             = try(int.ospf.authentication_md5_key, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.authentication_md5_key, null)
        ospf_authentication_md5_key_secure_mode = try(int.ospf.authentication_md5_key_secure_mode, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.authentication_md5_key_secure_mode, false)
        ospf_authentication_type                = try(int.ospf.authentication_type, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.authentication_type, null)
        ospf_advertise_subnet                   = try(int.ospf.advertise_subnet, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.advertise_subnet, false)
        ospf_mtu_ignore                         = try(int.ospf.mtu_ignore, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.mtu_ignore, false)
        ospf_node_flag                          = try(int.ospf.node_flag, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.node_flag, null)
        ospf_retransmit_interval                = try(int.ospf.retransmit_interval, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.retransmit_interval, null)
        ospf_transmit_delay                     = try(int.ospf.transmit_delay, local.defaults.nxos.devices.configuration.interfaces.port_channels.ospf.transmit_delay, null)
        pim_admin_state                         = try(int.pim.admin_state, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.admin_state, null)
        pim_bfd                                 = try(int.pim.bfd, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.bfd, null)
        pim_dr_priority                         = try(int.pim.dr_priority, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.dr_priority, null)
        pim_passive                             = try(int.pim.passive, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.passive, null)
        pim_sparse_mode                         = try(int.pim.sparse_mode, local.defaults.nxos.devices.configuration.interfaces.port_channels.pim.sparse_mode, null)
      }
    ]
  ])
}

resource "nxos_port_channel_interface" "port_channel_interface" {
  for_each = { for device in local.devices : device.name => device
  if length(try(local.device_config[device.name].interfaces.port_channels, [])) > 0 }
  device = each.key
  port_channel_interfaces = { for int in try(local.device_config[each.key].interfaces.port_channels, []) : "po${int.id}" => {
    port_channel_mode      = try(int.port_channel_mode, local.defaults.nxos.devices.configuration.interfaces.port_channels.port_channel_mode, null)
    minimum_links          = try(int.minimum_links, local.defaults.nxos.devices.configuration.interfaces.port_channels.minimum_links, null)
    maximum_links          = try(int.maximum_links, local.defaults.nxos.devices.configuration.interfaces.port_channels.maximum_links, null)
    suspend_individual     = try(int.suspend_individual, local.defaults.nxos.devices.configuration.interfaces.port_channels.suspend_individual, null) != null ? (try(int.suspend_individual, local.defaults.nxos.devices.configuration.interfaces.port_channels.suspend_individual) ? "enable" : "disable") : null
    access_vlan            = try(int.layer3, local.defaults.nxos.devices.configuration.interfaces.port_channels.layer3, false) ? "unknown" : "vlan-${try(int.access_vlan, local.defaults.nxos.devices.configuration.interfaces.port_channels.access_vlan, 1)}"
    admin_state            = try(int.admin_state, local.defaults.nxos.devices.configuration.interfaces.port_channels.admin_state, false) ? "up" : "down"
    auto_negotiation       = try(int.auto_negotiation, local.defaults.nxos.devices.configuration.interfaces.port_channels.auto_negotiation, null)
    bandwidth              = try(int.bandwidth, local.defaults.nxos.devices.configuration.interfaces.port_channels.bandwidth, null)
    delay                  = try(int.delay, local.defaults.nxos.devices.configuration.interfaces.port_channels.delay, null)
    description            = try(int.description, local.defaults.nxos.devices.configuration.interfaces.port_channels.description, null)
    duplex                 = try(int.duplex, local.defaults.nxos.devices.configuration.interfaces.port_channels.duplex, null)
    layer                  = try(int.layer3, local.defaults.nxos.devices.configuration.interfaces.port_channels.layer3, false) ? "Layer3" : "Layer2"
    link_logging           = try(int.link_logging, local.defaults.nxos.devices.configuration.interfaces.port_channels.link_logging, null) != null ? (try(int.link_logging, local.defaults.nxos.devices.configuration.interfaces.port_channels.link_logging) ? "enable" : "disable") : null
    medium                 = try(int.medium, local.defaults.nxos.devices.configuration.interfaces.port_channels.medium, null)
    mode                   = try(int.mode, local.defaults.nxos.devices.configuration.interfaces.port_channels.mode, null)
    mtu                    = try(int.mtu, local.defaults.nxos.devices.configuration.interfaces.port_channels.mtu, null)
    native_vlan            = try(int.layer3, local.defaults.nxos.devices.configuration.interfaces.port_channels.layer3, false) ? "unknown" : "vlan-${try(int.native_vlan, local.defaults.nxos.devices.configuration.interfaces.port_channels.native_vlan, 1)}"
    speed                  = try(int.speed, local.defaults.nxos.devices.configuration.interfaces.port_channels.speed, null)
    trunk_vlans            = try(int.layer3, local.defaults.nxos.devices.configuration.interfaces.port_channels.layer3, false) ? "1-4094" : try(int.trunk_vlans, local.defaults.nxos.devices.configuration.interfaces.port_channels.trunk_vlans, null)
    dot1q_ether_type       = try(int.dot1q_ether_type, local.defaults.nxos.devices.configuration.interfaces.port_channels.dot1q_ether_type, null)
    equalization_delay     = try(int.equalization_delay, local.defaults.nxos.devices.configuration.interfaces.port_channels.equalization_delay, null)
    graceful_convergence   = try(int.graceful_convergence, local.defaults.nxos.devices.configuration.interfaces.port_channels.graceful_convergence, null) != null ? (try(int.graceful_convergence, local.defaults.nxos.devices.configuration.interfaces.port_channels.graceful_convergence) ? "enable" : "disable") : null
    hash_distribution      = try(int.hash_distribution, local.defaults.nxos.devices.configuration.interfaces.port_channels.hash_distribution, null)
    inherit_bandwidth      = try(int.inherit_bandwidth, local.defaults.nxos.devices.configuration.interfaces.port_channels.inherit_bandwidth, null)
    itu_channel            = try(int.itu_channel, local.defaults.nxos.devices.configuration.interfaces.port_channels.itu_channel, null)
    lacp_delay_mode        = try(int.lacp_delay_mode, local.defaults.nxos.devices.configuration.interfaces.port_channels.lacp_delay_mode, null) != null ? (try(int.lacp_delay_mode, local.defaults.nxos.devices.configuration.interfaces.port_channels.lacp_delay_mode) ? "enable" : "disable") : null
    lacp_vpc_convergence   = try(int.lacp_vpc_convergence, local.defaults.nxos.devices.configuration.interfaces.port_channels.lacp_vpc_convergence, null) != null ? (try(int.lacp_vpc_convergence, local.defaults.nxos.devices.configuration.interfaces.port_channels.lacp_vpc_convergence) ? "enable" : "disable") : null
    link_debounce_down     = try(int.link_debounce_down, local.defaults.nxos.devices.configuration.interfaces.port_channels.link_debounce_down, null)
    load_defer             = try(int.load_defer, local.defaults.nxos.devices.configuration.interfaces.port_channels.load_defer, null) != null ? (try(int.load_defer, local.defaults.nxos.devices.configuration.interfaces.port_channels.load_defer) ? "enable" : "disable") : null
    mdix                   = try(int.mdix, local.defaults.nxos.devices.configuration.interfaces.port_channels.mdix, null)
    optics_loopback        = try(int.optics_loopback, local.defaults.nxos.devices.configuration.interfaces.port_channels.optics_loopback, null)
    port_type              = try(int.port_type, local.defaults.nxos.devices.configuration.interfaces.port_channels.port_type, null)
    pxe_transition_timeout = try(int.pxe_transition_timeout, local.defaults.nxos.devices.configuration.interfaces.port_channels.pxe_transition_timeout, null)
    router_mac             = try(int.router_mac, local.defaults.nxos.devices.configuration.interfaces.port_channels.router_mac, null)
    snmp_trap_state        = try(int.snmp_trap_link_status, local.defaults.nxos.devices.configuration.interfaces.port_channels.snmp_trap_link_status, null) != null ? (try(int.snmp_trap_link_status, local.defaults.nxos.devices.configuration.interfaces.port_channels.snmp_trap_link_status) ? "enable" : "disable") : null
    span_mode              = try(int.span_mode, local.defaults.nxos.devices.configuration.interfaces.port_channels.span_mode, null)
    squelch                = try(int.squelch, local.defaults.nxos.devices.configuration.interfaces.port_channels.squelch, null) != null ? (try(int.squelch, local.defaults.nxos.devices.configuration.interfaces.port_channels.squelch) ? "enable" : "disable") : null
    transmission_mode      = try(int.transparent_mode, local.defaults.nxos.devices.configuration.interfaces.port_channels.transparent_mode, null)
    trunk_logging          = try(int.trunk_logging, local.defaults.nxos.devices.configuration.interfaces.port_channels.trunk_logging, null) != null ? (try(int.trunk_logging, local.defaults.nxos.devices.configuration.interfaces.port_channels.trunk_logging) ? "enable" : "disable") : null
    usage                  = try(int.usage, local.defaults.nxos.devices.configuration.interfaces.port_channels.usage, null)
    user_configured_flags  = "admin_layer,admin_mtu,admin_state"
    vrf_dn                 = try(int.layer3, local.defaults.nxos.devices.configuration.interfaces.port_channels.layer3, false) ? "sys/inst-${try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.port_channels.vrf, "default")}" : null
    members = { for eth in try(local.device_config[each.key].interfaces.ethernets, []) : "sys/intf/phys-[eth${eth.id}]" => {
      force = try(eth.port_channel_force, local.defaults.nxos.devices.configuration.interfaces.ethernets.port_channel_force, false)
    } if try(eth.port_channel, null) == int.id }
  } }
  depends_on = [nxos_physical_interface.physical_interface]
}

locals {
  interfaces_loopbacks = flatten([
    for device in local.devices : [
      for int in try(local.device_config[device.name].interfaces.loopbacks, []) : {
        key                                     = format("%s/%s", device.name, int.id)
        device                                  = device.name
        id                                      = int.id
        type                                    = "lo"
        admin_state                             = try(int.admin_state, local.defaults.nxos.devices.configuration.interfaces.loopbacks.admin_state, false)
        description                             = try(int.description, local.defaults.nxos.devices.configuration.interfaces.loopbacks.description, null)
        vrf                                     = try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.loopbacks.vrf, "default")
        ipv4_address                            = try(int.ipv4_address, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ipv4_address, null)
        ospf_process_name                       = try(int.ospf.process_name, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.process_name, null)
        ospf_advertise_secondaries              = try(int.ospf.advertise_secondaries, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.advertise_secondaries, false)
        ospf_area                               = try(int.ospf.area, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.area, null)
        ospf_bfd                                = try(int.ospf.bfd, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.bfd, null)
        ospf_cost                               = try(int.ospf.cost, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.cost, null)
        ospf_dead_interval                      = try(int.ospf.dead_interval, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.dead_interval, null)
        ospf_hello_interval                     = try(int.ospf.hello_interval, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.hello_interval, null)
        ospf_network_type                       = try(int.ospf.network_type, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.network_type, null)
        ospf_passive                            = try(int.ospf.passive, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.passive, null)
        ospf_priority                           = try(int.ospf.priority, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.priority, null)
        ospf_authentication_key                 = try(int.ospf.authentication_key, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.authentication_key, null)
        ospf_authentication_key_id              = try(int.ospf.authentication_key_id, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.authentication_key_id, null)
        ospf_authentication_key_secure_mode     = try(int.ospf.authentication_key_secure_mode, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.authentication_key_secure_mode, false)
        ospf_authentication_keychain            = try(int.ospf.authentication_keychain, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.authentication_keychain, null)
        ospf_authentication_md5_key             = try(int.ospf.authentication_md5_key, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.authentication_md5_key, null)
        ospf_authentication_md5_key_secure_mode = try(int.ospf.authentication_md5_key_secure_mode, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.authentication_md5_key_secure_mode, false)
        ospf_authentication_type                = try(int.ospf.authentication_type, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.authentication_type, null)
        ospf_advertise_subnet                   = try(int.ospf.advertise_subnet, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.advertise_subnet, false)
        ospf_mtu_ignore                         = try(int.ospf.mtu_ignore, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.mtu_ignore, false)
        ospf_node_flag                          = try(int.ospf.node_flag, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.node_flag, null)
        ospf_retransmit_interval                = try(int.ospf.retransmit_interval, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.retransmit_interval, null)
        ospf_transmit_delay                     = try(int.ospf.transmit_delay, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.transmit_delay, null)
        pim_admin_state                         = try(int.pim.admin_state, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.admin_state, null)
        pim_bfd                                 = try(int.pim.bfd, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.bfd, null)
        pim_dr_priority                         = try(int.pim.dr_priority, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.dr_priority, null)
        pim_passive                             = try(int.pim.passive, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.passive, null)
        pim_sparse_mode                         = try(int.pim.sparse_mode, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.sparse_mode, null)
      }
    ]
  ])
}

resource "nxos_loopback_interface" "loopback_interface" {
  for_each = { for device in local.devices : device.name => device
  if length(try(local.device_config[device.name].interfaces.loopbacks, [])) > 0 }
  device = each.key
  loopback_interfaces = { for int in try(local.device_config[each.key].interfaces.loopbacks, []) : "lo${int.id}" => {
    admin_state  = try(int.admin_state, local.defaults.nxos.devices.configuration.interfaces.loopbacks.admin_state, false) ? "up" : "down"
    description  = try(int.description, local.defaults.nxos.devices.configuration.interfaces.loopbacks.description, null)
    link_logging = try(int.link_logging, local.defaults.nxos.devices.configuration.interfaces.loopbacks.link_logging, null)
    vrf_dn       = "sys/inst-${try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.loopbacks.vrf, "default")}"
  } }
}


locals {
  interfaces_vlans = flatten([
    for device in local.devices : [
      for int in try(local.device_config[device.name].interfaces.vlans, []) : {
        key                                     = format("%s/%s", device.name, int.id)
        device                                  = device.name
        id                                      = int.id
        type                                    = "vlan"
        admin_state                             = try(int.admin_state, local.defaults.nxos.devices.configuration.interfaces.vlans.admin_state, false)
        description                             = try(int.description, local.defaults.nxos.devices.configuration.interfaces.vlans.description, null)
        vrf                                     = try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.vlans.vrf, "default")
        ipv4_address                            = try(int.ipv4_address, local.defaults.nxos.devices.configuration.interfaces.vlans.ipv4_address, null)
        delay                                   = try(int.delay, local.defaults.nxos.devices.configuration.interfaces.vlans.delay, null)
        bandwidth                               = try(int.bandwidth, local.defaults.nxos.devices.configuration.interfaces.vlans.bandwidth, null)
        ip_forward                              = try(int.ip_forward, local.defaults.nxos.devices.configuration.interfaces.vlans.ip_forward, false)
        ip_drop_glean                           = try(int.ip_drop_glean, local.defaults.nxos.devices.configuration.interfaces.vlans.ip_drop_glean, false)
        medium                                  = try(int.medium, local.defaults.nxos.devices.configuration.interfaces.vlans.medium, null)
        mtu                                     = try(int.mtu, local.defaults.nxos.devices.configuration.interfaces.vlans.mtu, null)
        fabric_forwarding_mode                  = try(int.fabric_forwarding_mode, local.defaults.nxos.devices.configuration.interfaces.vlans.fabric_forwarding_mode, null)
        ospf_process_name                       = try(int.ospf.process_name, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.process_name, null)
        ospf_advertise_secondaries              = try(int.ospf.advertise_secondaries, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.advertise_secondaries, false)
        ospf_area                               = try(int.ospf.area, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.area, null)
        ospf_bfd                                = try(int.ospf.bfd, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.bfd, null)
        ospf_cost                               = try(int.ospf.cost, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.cost, null)
        ospf_dead_interval                      = try(int.ospf.dead_interval, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.dead_interval, null)
        ospf_hello_interval                     = try(int.ospf.hello_interval, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.hello_interval, null)
        ospf_network_type                       = try(int.ospf.network_type, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.network_type, null)
        ospf_passive                            = try(int.ospf.passive, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.passive, null)
        ospf_priority                           = try(int.ospf.priority, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.priority, null)
        ospf_authentication_key                 = try(int.ospf.authentication_key, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.authentication_key, null)
        ospf_authentication_key_id              = try(int.ospf.authentication_key_id, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.authentication_key_id, null)
        ospf_authentication_key_secure_mode     = try(int.ospf.authentication_key_secure_mode, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.authentication_key_secure_mode, false)
        ospf_authentication_keychain            = try(int.ospf.authentication_keychain, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.authentication_keychain, null)
        ospf_authentication_md5_key             = try(int.ospf.authentication_md5_key, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.authentication_md5_key, null)
        ospf_authentication_md5_key_secure_mode = try(int.ospf.authentication_md5_key_secure_mode, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.authentication_md5_key_secure_mode, false)
        ospf_authentication_type                = try(int.ospf.authentication_type, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.authentication_type, null)
        ospf_advertise_subnet                   = try(int.ospf.advertise_subnet, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.advertise_subnet, false)
        ospf_mtu_ignore                         = try(int.ospf.mtu_ignore, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.mtu_ignore, false)
        ospf_node_flag                          = try(int.ospf.node_flag, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.node_flag, null)
        ospf_retransmit_interval                = try(int.ospf.retransmit_interval, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.retransmit_interval, null)
        ospf_transmit_delay                     = try(int.ospf.transmit_delay, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.transmit_delay, null)
        pim_admin_state                         = try(int.pim.admin_state, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.admin_state, null)
        pim_bfd                                 = try(int.pim.bfd, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.bfd, null)
        pim_dr_priority                         = try(int.pim.dr_priority, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.dr_priority, null)
        pim_passive                             = try(int.pim.passive, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.passive, null)
        pim_sparse_mode                         = try(int.pim.sparse_mode, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.sparse_mode, null)
      }
    ]
  ])
}

resource "nxos_svi_interface" "svi_interface" {
  for_each = { for device in local.devices : device.name => device
  if length(try(local.device_config[device.name].interfaces.vlans, [])) > 0 }
  device = each.key
  svi_interfaces = { for int in try(local.device_config[each.key].interfaces.vlans, []) : "vlan${int.id}" => {
    admin_state = try(int.admin_state, local.defaults.nxos.devices.configuration.interfaces.vlans.admin_state, false) ? "up" : "down"
    bandwidth   = try(int.bandwidth, local.defaults.nxos.devices.configuration.interfaces.vlans.bandwidth, null)
    delay       = try(int.delay, local.defaults.nxos.devices.configuration.interfaces.vlans.delay, null)
    description = try(int.description, local.defaults.nxos.devices.configuration.interfaces.vlans.description, null)
    medium      = try(int.medium, local.defaults.nxos.devices.configuration.interfaces.vlans.medium, null)
    mtu         = try(int.mtu, local.defaults.nxos.devices.configuration.interfaces.vlans.mtu, null)
    vrf_dn      = "sys/inst-${try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.vlans.vrf, "default")}"
  } }
}


resource "nxos_subinterface" "subinterface" {
  for_each = { for device in local.devices : device.name => device
    if length(try(flatten([for int in try(local.device_config[device.name].interfaces.ethernets, []) : try(int.subinterfaces, [])]), [])) > 0 ||
  length(try(flatten([for int in try(local.device_config[device.name].interfaces.port_channels, []) : try(int.subinterfaces, [])]), [])) > 0 }
  device = each.key
  subinterfaces = merge(
    { for sub in flatten([for int in try(local.device_config[each.key].interfaces.ethernets, []) : [
      for s in try(int.subinterfaces, []) : merge(s, { parent_id = "eth${int.id}" })
      ]]) : "${sub.parent_id}.${sub.id}" => {
      admin_state             = try(sub.admin_state, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.admin_state, null) != null ? (try(sub.admin_state, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.admin_state) ? "up" : "down") : null
      bandwidth               = try(sub.bandwidth, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.bandwidth, null)
      delay                   = try(sub.delay, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.delay, null)
      description             = try(sub.description, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.description, null)
      encap                   = try(sub.encapsulation, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.encapsulation, null)
      link_logging            = try(sub.link_logging, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.link_logging, null) != null ? (try(sub.link_logging, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.link_logging) ? "enable" : "disable") : null
      medium                  = try(sub.medium, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.medium, null)
      mtu                     = try(sub.mtu, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.mtu, null)
      mtu_inherit             = try(sub.mtu_inherit, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.mtu_inherit, null)
      router_mac              = try(sub.mac, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.mac, null)
      router_mac_ipv6_extract = try(sub.mac_ipv6_extract, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.mac_ipv6_extract, null) != null ? (try(sub.mac_ipv6_extract, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.mac_ipv6_extract) ? "enable" : "disable") : null
      snmp_trap               = try(sub.snmp_trap, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.snmp_trap, null) != null ? (try(sub.snmp_trap, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.snmp_trap) ? "enable" : "disable") : null
      vrf_dn                  = try(sub.vrf, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.vrf, null) != null ? "sys/inst-${try(sub.vrf, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.vrf)}" : null
    } },
    { for sub in flatten([for int in try(local.device_config[each.key].interfaces.port_channels, []) : [
      for s in try(int.subinterfaces, []) : merge(s, { parent_id = "po${int.id}" })
      ]]) : "${sub.parent_id}.${sub.id}" => {
      admin_state             = try(sub.admin_state, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.admin_state, null) != null ? (try(sub.admin_state, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.admin_state) ? "up" : "down") : null
      bandwidth               = try(sub.bandwidth, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.bandwidth, null)
      delay                   = try(sub.delay, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.delay, null)
      description             = try(sub.description, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.description, null)
      encap                   = try(sub.encapsulation, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.encapsulation, null)
      link_logging            = try(sub.link_logging, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.link_logging, null) != null ? (try(sub.link_logging, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.link_logging) ? "enable" : "disable") : null
      medium                  = try(sub.medium, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.medium, null)
      mtu                     = try(sub.mtu, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.mtu, null)
      mtu_inherit             = try(sub.mtu_inherit, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.mtu_inherit, null)
      router_mac              = try(sub.mac, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.mac, null)
      router_mac_ipv6_extract = try(sub.mac_ipv6_extract, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.mac_ipv6_extract, null) != null ? (try(sub.mac_ipv6_extract, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.mac_ipv6_extract) ? "enable" : "disable") : null
      snmp_trap               = try(sub.snmp_trap, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.snmp_trap, null) != null ? (try(sub.snmp_trap, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.snmp_trap) ? "enable" : "disable") : null
      vrf_dn                  = try(sub.vrf, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.vrf, null) != null ? "sys/inst-${try(sub.vrf, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.vrf)}" : null
    } },
  )
  depends_on = [nxos_physical_interface.physical_interface, nxos_port_channel_interface.port_channel_interface]
}
