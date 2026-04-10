locals {
  hsrp_interfaces = flatten([
    for device in local.devices : concat(
      [for int in try(local.device_config[device.name].interfaces.vlans, []) : {
        key    = format("%s/vlan%s", device.name, int.id)
        device = device.name
        id     = "vlan${int.id}"
        hsrp   = try(int.hsrp, null)
      } if try(int.hsrp, null) != null],
      [for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        key    = format("%s/eth%s", device.name, int.id)
        device = device.name
        id     = "eth${int.id}"
        hsrp   = try(int.hsrp, null)
      } if try(int.hsrp, null) != null],
      [for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        key    = format("%s/po%s", device.name, int.id)
        device = device.name
        id     = "po${int.id}"
        hsrp   = try(int.hsrp, null)
      } if try(int.hsrp, null) != null],
      flatten([for eth in try(local.device_config[device.name].interfaces.ethernets, []) :
        [for sub in try(eth.subinterfaces, []) : {
          key    = format("%s/%s", device.name, sub.id)
          device = device.name
          id     = sub.id
          hsrp   = try(sub.hsrp, null)
        } if try(sub.hsrp, null) != null]
      ]),
      flatten([for pc in try(local.device_config[device.name].interfaces.port_channels, []) :
        [for sub in try(pc.subinterfaces, []) : {
          key    = format("%s/%s", device.name, sub.id)
          device = device.name
          id     = sub.id
          hsrp   = try(sub.hsrp, null)
        } if try(sub.hsrp, null) != null]
      ]),
    )
  ])
}

resource "nxos_hsrp" "hsrp" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].system.hsrp_bfd, null) != null ||
    try(local.device_config[device.name].system.hsrp_timers_extended_hold, null) != null ||
  length([for int in local.hsrp_interfaces : int if int.device == device.name]) > 0 }
  device                               = each.key
  admin_state                          = "enabled"
  instance_admin_state                 = "enabled"
  bfd                                  = try(local.device_config[each.key].system.hsrp_bfd, null) == null ? null : (try(local.device_config[each.key].system.hsrp_bfd) ? "enabled" : "disabled")
  extended_hold_interval               = try(local.device_config[each.key].system.hsrp_timers_extended_hold, null)
  extended_hold_interval_configuration = try(local.device_config[each.key].system.hsrp_timers_extended_hold, null) != null ? "enabled" : null

  interfaces = { for int in local.hsrp_interfaces : int.id => {
    admin_state                        = "enabled"
    bfd                                = try(int.hsrp.bfd, null) == null ? null : (try(int.hsrp.bfd) ? "enabled" : "disabled")
    bia_scope                          = try(int.hsrp.use_bia_scope, null)
    control                            = try(int.hsrp.use_bia, null) == null ? null : (try(int.hsrp.use_bia) ? "bia" : "")
    delay_minimum                      = try(int.hsrp.delay_minimum, null)
    mac_refresh_interval               = try(int.hsrp.mac_refresh, null)
    mac_refresh_interval_configuration = try(int.hsrp.mac_refresh, null) != null ? "enabled" : null
    reload_delay                       = try(int.hsrp.delay_reload, null)
    version                            = try(int.hsrp.version, null) == null ? null : "v${try(int.hsrp.version)}"

    groups = { for group in try(int.hsrp.groups, []) : "${group.id};${group.address_family}" => {
      authentication_md5_compatibility_mode = try(group.authentication_md5_compatibility, null) == null ? null : (try(group.authentication_md5_compatibility) ? "enabled" : "disabled")
      authentication_md5_key_chain_name     = try(group.authentication_md5_key_chain, null)
      authentication_md5_key_name           = try(group.authentication_md5_key_string, null)
      authentication_md5_key_string_type    = try(group.authentication_md5_key_string_type, null)
      authentication_md5_timeout            = try(group.authentication_md5_timeout, null)
      authentication_md5_type               = try(group.authentication_md5_type, null)
      authentication_secret                 = try(group.authentication_text, null)
      authentication_type                   = try(group.authentication_type, null)
      control                               = try(group.preempt, null) == null ? null : (try(group.preempt) ? "preempt" : "")
      follow                                = try(group.follow, null)
      forwarding_lower_threshold            = try(group.forwarding_threshold_lower, null)
      hello_interval                        = try(group.timers_hello_interval, null)
      hold_interval                         = try(group.timers_hold_interval, null)
      ip_address                            = try(group.ip, null)
      ip_obtain_mode                        = try(group.ip, null) != null ? "admin" : null
      mac_address                           = try(group.mac_address, null)
      name                                  = try(group.name, null)
      preempt_delay_minimum                 = try(group.preempt_delay_minimum, null)
      preempt_delay_reload                  = try(group.preempt_delay_reload, null)
      preempt_delay_sync                    = try(group.preempt_delay_sync, null)
      priority                              = try(group.priority, null)
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
