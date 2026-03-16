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
