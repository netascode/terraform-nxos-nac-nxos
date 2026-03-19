locals {
  interfaces_vlans = flatten([
    for device in local.devices : [
      for int in try(local.device_config[device.name].interfaces.vlans, []) : {
        key                                     = format("%s/%s", device.name, int.id)
        device                                  = device.name
        id                                      = int.id
        type                                    = "vlan"
        admin_state                             = try(int.shutdown, local.defaults.nxos.devices.configuration.interfaces.vlans.shutdown, false)
        description                             = try(int.description, local.defaults.nxos.devices.configuration.interfaces.vlans.description, null)
        vrf                                     = try(int.vrf_member, local.defaults.nxos.devices.configuration.interfaces.vlans.vrf_member, "default")
        ip_address                              = try(int.ip_address, local.defaults.nxos.devices.configuration.interfaces.vlans.ip_address, null)
        delay                                   = try(int.delay, local.defaults.nxos.devices.configuration.interfaces.vlans.delay, null)
        bandwidth                               = try(int.bandwidth, local.defaults.nxos.devices.configuration.interfaces.vlans.bandwidth, null)
        ip_forward                              = try(int.ip_forward, local.defaults.nxos.devices.configuration.interfaces.vlans.ip_forward, false)
        ip_drop_glean                           = try(int.ip_drop_glean, local.defaults.nxos.devices.configuration.interfaces.vlans.ip_drop_glean, false)
        medium                                  = try(int.medium, local.defaults.nxos.devices.configuration.interfaces.vlans.medium, null)
        mtu                                     = try(int.mtu, local.defaults.nxos.devices.configuration.interfaces.vlans.mtu, null)
        fabric_forwarding_mode                  = try(int.fabric_forwarding_mode, local.defaults.nxos.devices.configuration.interfaces.vlans.fabric_forwarding_mode, null)
        ospf_process_name                       = try(int.ospf.process, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.process, null)
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
        ospfv3_process                          = try(int.ospfv3.process, local.defaults.nxos.devices.configuration.interfaces.vlans.ospfv3.process, null)
        ospfv3_advertise_secondaries            = try(int.ospfv3.advertise_secondaries, local.defaults.nxos.devices.configuration.interfaces.vlans.ospfv3.advertise_secondaries, null)
        ospfv3_area                             = try(int.ospfv3.area, local.defaults.nxos.devices.configuration.interfaces.vlans.ospfv3.area, null)
        ospfv3_bfd                              = try(int.ospfv3.bfd, local.defaults.nxos.devices.configuration.interfaces.vlans.ospfv3.bfd, null)
        ospfv3_cost                             = try(int.ospfv3.cost, local.defaults.nxos.devices.configuration.interfaces.vlans.ospfv3.cost, null)
        ospfv3_dead_interval                    = try(int.ospfv3.dead_interval, local.defaults.nxos.devices.configuration.interfaces.vlans.ospfv3.dead_interval, null)
        ospfv3_hello_interval                   = try(int.ospfv3.hello_interval, local.defaults.nxos.devices.configuration.interfaces.vlans.ospfv3.hello_interval, null)
        ospfv3_network_type                     = try(int.ospfv3.network_type, local.defaults.nxos.devices.configuration.interfaces.vlans.ospfv3.network_type, null)
        ospfv3_passive_interface                = try(int.ospfv3.passive_interface, local.defaults.nxos.devices.configuration.interfaces.vlans.ospfv3.passive_interface, null)
        ospfv3_priority                         = try(int.ospfv3.priority, local.defaults.nxos.devices.configuration.interfaces.vlans.ospfv3.priority, null)
        ospfv3_instance_id                      = try(int.ospfv3.instance_id, local.defaults.nxos.devices.configuration.interfaces.vlans.ospfv3.instance_id, null)
        ospfv3_mtu_ignore                       = try(int.ospfv3.mtu_ignore, local.defaults.nxos.devices.configuration.interfaces.vlans.ospfv3.mtu_ignore, null)
        ospfv3_retransmit_interval              = try(int.ospfv3.retransmit_interval, local.defaults.nxos.devices.configuration.interfaces.vlans.ospfv3.retransmit_interval, null)
        ospfv3_transmit_delay                   = try(int.ospfv3.transmit_delay, local.defaults.nxos.devices.configuration.interfaces.vlans.ospfv3.transmit_delay, null)
        pim_bfd                                 = try(int.pim.bfd, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.bfd, null)
        pim_dr_priority                         = try(int.pim.dr_priority, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.dr_priority, null)
        pim_passive                             = try(int.pim.passive, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.passive, null)
        pim_sparse_mode                         = try(int.pim.sparse_mode, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.sparse_mode, null)
        isis_instance_name                      = try(int.isis.instance_name, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.instance_name, null)
        isis_circuit_type                       = try(int.isis.circuit_type, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.circuit_type, null)
        isis_ipv4                               = try(int.isis.ipv4, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.ipv4, null)
        isis_ipv6                               = try(int.isis.ipv6, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.ipv6, null)
        isis_network_type_p2p                   = try(int.isis.network_type_p2p, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.network_type_p2p, null)
        isis_passive                            = try(int.isis.passive, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.passive, null)
        isis_metric_l1                          = try(int.isis.metric_l1, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.metric_l1, null)
        isis_metric_l2                          = try(int.isis.metric_l2, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.metric_l2, null)
        isis_ipv6_metric_l1                     = try(int.isis.ipv6_metric_l1, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.ipv6_metric_l1, null)
        isis_ipv6_metric_l2                     = try(int.isis.ipv6_metric_l2, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.ipv6_metric_l2, null)
        isis_priority_l1                        = try(int.isis.priority_l1, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.priority_l1, null)
        isis_priority_l2                        = try(int.isis.priority_l2, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.priority_l2, null)
        isis_hello_interval                     = try(int.isis.hello_interval, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.hello_interval, null)
        isis_hello_interval_l1                  = try(int.isis.hello_interval_l1, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.hello_interval_l1, null)
        isis_hello_interval_l2                  = try(int.isis.hello_interval_l2, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.hello_interval_l2, null)
        isis_hello_multiplier                   = try(int.isis.hello_multiplier, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.hello_multiplier, null)
        isis_hello_multiplier_l1                = try(int.isis.hello_multiplier_l1, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.hello_multiplier_l1, null)
        isis_hello_multiplier_l2                = try(int.isis.hello_multiplier_l2, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.hello_multiplier_l2, null)
        isis_hello_padding                      = try(int.isis.hello_padding, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.hello_padding, null)
        isis_authentication_check               = try(int.isis.authentication_check, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.authentication_check, null)
        isis_authentication_check_l1            = try(int.isis.authentication_check_l1, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.authentication_check_l1, null)
        isis_authentication_check_l2            = try(int.isis.authentication_check_l2, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.authentication_check_l2, null)
        isis_authentication_key                 = try(int.isis.authentication_key, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.authentication_key, null)
        isis_authentication_key_l1              = try(int.isis.authentication_key_l1, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.authentication_key_l1, null)
        isis_authentication_key_l2              = try(int.isis.authentication_key_l2, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.authentication_key_l2, null)
        isis_authentication_type                = try(int.isis.authentication_type, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.authentication_type, null)
        isis_authentication_type_l1             = try(int.isis.authentication_type_l1, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.authentication_type_l1, null)
        isis_authentication_type_l2             = try(int.isis.authentication_type_l2, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.authentication_type_l2, null)
        isis_mtu_check                          = try(int.isis.mtu_check, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.mtu_check, null)
        isis_mtu_check_l1                       = try(int.isis.mtu_check_l1, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.mtu_check_l1, null)
        isis_mtu_check_l2                       = try(int.isis.mtu_check_l2, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.mtu_check_l2, null)
        isis_ipv4_bfd                           = try(int.isis.ipv4_bfd, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.ipv4_bfd, null)
        isis_ipv6_bfd                           = try(int.isis.ipv6_bfd, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.ipv6_bfd, null)
        isis_csnp_interval_l1                   = try(int.isis.csnp_interval_l1, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.csnp_interval_l1, null)
        isis_csnp_interval_l2                   = try(int.isis.csnp_interval_l2, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.csnp_interval_l2, null)
        isis_lsp_refresh_interval               = try(int.isis.lsp_refresh_interval, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.lsp_refresh_interval, null)
        isis_retransmit_interval                = try(int.isis.retransmit_interval, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.retransmit_interval, null)
        isis_retransmit_throttle_interval       = try(int.isis.retransmit_throttle_interval, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.retransmit_throttle_interval, null)
        isis_mesh_group_id                      = try(int.isis.mesh_group_id, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.mesh_group_id, null)
        isis_mesh_group_blocked                 = try(int.isis.mesh_group_blocked, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.mesh_group_blocked, null)
        isis_n_flag_clear                       = try(int.isis.n_flag_clear, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.n_flag_clear, null)
        isis_suppressed_state                   = try(int.isis.suppressed_state, local.defaults.nxos.devices.configuration.interfaces.vlans.isis.suppressed_state, null)
      }
    ]
  ])
}

resource "nxos_svi_interface" "svi_interface" {
  for_each = { for device in local.devices : device.name => device
  if length(try(local.device_config[device.name].interfaces.vlans, [])) > 0 }
  device = each.key
  svi_interfaces = { for int in try(local.device_config[each.key].interfaces.vlans, []) : "vlan${int.id}" => {
    admin_state = try(int.shutdown, local.defaults.nxos.devices.configuration.interfaces.vlans.shutdown, false) ? "down" : "up"
    bandwidth   = try(int.bandwidth, local.defaults.nxos.devices.configuration.interfaces.vlans.bandwidth, null)
    delay       = try(int.delay, local.defaults.nxos.devices.configuration.interfaces.vlans.delay, null)
    description = try(int.description, local.defaults.nxos.devices.configuration.interfaces.vlans.description, null)
    medium      = try(int.medium, local.defaults.nxos.devices.configuration.interfaces.vlans.medium, null) == "broadcast" ? "bcast" : try(int.medium, local.defaults.nxos.devices.configuration.interfaces.vlans.medium, null)
    mtu         = try(int.mtu, local.defaults.nxos.devices.configuration.interfaces.vlans.mtu, null)
    vrf_dn      = "sys/inst-${try(int.vrf_member, local.defaults.nxos.devices.configuration.interfaces.vlans.vrf_member, "default")}"
  } }

  depends_on = [
    nxos_feature.feature,
    nxos_bridge_domain.bridge_domain,
    nxos_vrf.vrf,
  ]
}
