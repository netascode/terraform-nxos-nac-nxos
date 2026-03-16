locals {
  hsrp_interfaces = flatten([
    for device in local.devices : concat(
      [for int in try(local.device_config[device.name].interfaces.vlans, []) : {
        key           = format("%s/vlan%s", device.name, int.id)
        device        = device.name
        id            = "vlan${int.id}"
        hsrp          = try(int.hsrp, null)
        defaults_path = local.defaults.nxos.devices.configuration.interfaces.vlans
      } if try(int.hsrp, null) != null],
      [for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        key           = format("%s/%s", device.name, int.id)
        device        = device.name
        id            = int.id
        hsrp          = try(int.hsrp, null)
        defaults_path = local.defaults.nxos.devices.configuration.interfaces.ethernets
      } if try(int.hsrp, null) != null],
      [for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        key           = format("%s/po%s", device.name, int.id)
        device        = device.name
        id            = "po${int.id}"
        hsrp          = try(int.hsrp, null)
        defaults_path = local.defaults.nxos.devices.configuration.interfaces.port_channels
      } if try(int.hsrp, null) != null],
      flatten([for eth in try(local.device_config[device.name].interfaces.ethernets, []) :
        [for sub in try(eth.subinterfaces, []) : {
          key           = format("%s/%s", device.name, sub.id)
          device        = device.name
          id            = sub.id
          hsrp          = try(sub.hsrp, null)
          defaults_path = local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces
        } if try(sub.hsrp, null) != null]
      ]),
      flatten([for pc in try(local.device_config[device.name].interfaces.port_channels, []) :
        [for sub in try(pc.subinterfaces, []) : {
          key           = format("%s/%s", device.name, sub.id)
          device        = device.name
          id            = sub.id
          hsrp          = try(sub.hsrp, null)
          defaults_path = local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces
        } if try(sub.hsrp, null) != null]
      ]),
    )
  ])
}

resource "nxos_hsrp" "hsrp" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].hsrp, null) != null ||
  length([for int in local.hsrp_interfaces : int if int.device == device.name]) > 0 }
  device                               = each.key
  admin_state                          = "enabled"
  instance_admin_state                 = "enabled"
  bfd                                  = try(local.device_config[each.key].hsrp.bfd, local.defaults.nxos.devices.configuration.hsrp.bfd, null) == null ? null : (try(local.device_config[each.key].hsrp.bfd, local.defaults.nxos.devices.configuration.hsrp.bfd) ? "enabled" : "disabled")
  control                              = try(local.device_config[each.key].hsrp.stateful_ha, local.defaults.nxos.devices.configuration.hsrp.stateful_ha, null) == null ? null : (try(local.device_config[each.key].hsrp.stateful_ha, local.defaults.nxos.devices.configuration.hsrp.stateful_ha) ? "stateful-ha" : "")
  extended_hold_interval               = try(local.device_config[each.key].hsrp.extended_hold_interval, local.defaults.nxos.devices.configuration.hsrp.extended_hold_interval, null)
  extended_hold_interval_configuration = try(local.device_config[each.key].hsrp.extended_hold_interval, local.defaults.nxos.devices.configuration.hsrp.extended_hold_interval, null) != null ? "enabled" : null

  interfaces = { for int in local.hsrp_interfaces : int.id => {
    admin_state                        = "enabled"
    bfd                                = try(int.hsrp.bfd, try(int.defaults_path.hsrp.bfd, null), null) == null ? null : (try(int.hsrp.bfd, try(int.defaults_path.hsrp.bfd, null)) ? "enabled" : "disabled")
    bia_scope                          = try(int.hsrp.bia_scope, try(int.defaults_path.hsrp.bia_scope, null), null)
    control                            = try(int.hsrp.use_bia, try(int.defaults_path.hsrp.use_bia, null), null) == null ? null : (try(int.hsrp.use_bia, try(int.defaults_path.hsrp.use_bia, null)) ? "bia" : "")
    delay_minimum                      = try(int.hsrp.delay_minimum, try(int.defaults_path.hsrp.delay_minimum, null), null)
    mac_refresh_interval               = try(int.hsrp.mac_refresh_interval, try(int.defaults_path.hsrp.mac_refresh_interval, null), null)
    mac_refresh_interval_configuration = try(int.hsrp.mac_refresh_interval, try(int.defaults_path.hsrp.mac_refresh_interval, null), null) != null ? "enabled" : null
    reload_delay                       = try(int.hsrp.reload_delay, try(int.defaults_path.hsrp.reload_delay, null), null)
    version                            = try(int.hsrp.version, try(int.defaults_path.hsrp.version, null), null) == null ? null : "v${try(int.hsrp.version, try(int.defaults_path.hsrp.version, null))}"

    groups = { for group in try(int.hsrp.groups, []) : "${group.id};${group.address_family}" => {
      authentication_md5_compatibility_mode = try(group.authentication_md5_compatibility_mode, try(int.defaults_path.hsrp.groups.authentication_md5_compatibility_mode, null), null) == null ? null : (try(group.authentication_md5_compatibility_mode, try(int.defaults_path.hsrp.groups.authentication_md5_compatibility_mode, null)) ? "enabled" : "disabled")
      authentication_md5_key_chain_name     = try(group.authentication_md5_key_chain, try(int.defaults_path.hsrp.groups.authentication_md5_key_chain, null), null)
      authentication_md5_key_name           = try(group.authentication_md5_key_string, try(int.defaults_path.hsrp.groups.authentication_md5_key_string, null), null)
      authentication_md5_key_string_type    = try(group.authentication_md5_key_string_type, try(int.defaults_path.hsrp.groups.authentication_md5_key_string_type, null), null)
      authentication_md5_timeout            = try(group.authentication_md5_timeout, try(int.defaults_path.hsrp.groups.authentication_md5_timeout, null), null)
      authentication_md5_type               = try(group.authentication_md5_type, try(int.defaults_path.hsrp.groups.authentication_md5_type, null), null)
      authentication_secret                 = try(group.authentication_text, try(int.defaults_path.hsrp.groups.authentication_text, null), null)
      authentication_type                   = try(group.authentication_type, try(int.defaults_path.hsrp.groups.authentication_type, null), null)
      control                               = try(group.preempt, try(int.defaults_path.hsrp.groups.preempt, null), null) == null ? null : (try(group.preempt, try(int.defaults_path.hsrp.groups.preempt, null)) ? "preempt" : "")
      follow                                = try(group.follow, try(int.defaults_path.hsrp.groups.follow, null), null)
      forwarding_lower_threshold            = try(group.forwarding_lower_threshold, try(int.defaults_path.hsrp.groups.forwarding_lower_threshold, null), null)
      hello_interval                        = try(group.hello_interval, try(int.defaults_path.hsrp.groups.hello_interval, null), null)
      hold_interval                         = try(group.hold_interval, try(int.defaults_path.hsrp.groups.hold_interval, null), null)
      ip_address                            = try(group.ip_address, try(int.defaults_path.hsrp.groups.ip_address, null), null)
      ip_obtain_mode                        = try(group.ip_obtain_mode, try(int.defaults_path.hsrp.groups.ip_obtain_mode, null), null)
      mac_address                           = try(group.mac_address, try(int.defaults_path.hsrp.groups.mac_address, null), null)
      name                                  = try(group.name, try(int.defaults_path.hsrp.groups.name, null), null)
      preempt_delay_minimum                 = try(group.preempt_delay_minimum, try(int.defaults_path.hsrp.groups.preempt_delay_minimum, null), null)
      preempt_delay_reload                  = try(group.preempt_delay_reload, try(int.defaults_path.hsrp.groups.preempt_delay_reload, null), null)
      preempt_delay_sync                    = try(group.preempt_delay_sync, try(int.defaults_path.hsrp.groups.preempt_delay_sync, null), null)
      priority                              = try(group.priority, try(int.defaults_path.hsrp.groups.priority, null), null)
    } }
  } if int.device == each.key }

  depends_on = [
    nxos_feature.feature,
    nxos_physical_interface.physical_interface,
    nxos_svi_interface.svi_interface,
    nxos_port_channel_interface.port_channel_interface,
    nxos_subinterface.subinterface
  ]
}
