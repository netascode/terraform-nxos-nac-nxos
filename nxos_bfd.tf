locals {
  bfd_interfaces = flatten([
    for device in local.devices : concat(
      [for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        key    = format("%s/eth%s", device.name, int.id)
        device = device.name
        id     = "eth${int.id}"
        bfd    = try(int.bfd, null)
      } if try(int.bfd, null) != null],
      [for int in try(local.device_config[device.name].interfaces.vlans, []) : {
        key    = format("%s/vlan%s", device.name, int.id)
        device = device.name
        id     = "vlan${int.id}"
        bfd    = try(int.bfd, null)
      } if try(int.bfd, null) != null],
      [for int in try(local.device_config[device.name].interfaces.loopbacks, []) : {
        key    = format("%s/lo%s", device.name, int.id)
        device = device.name
        id     = "lo${int.id}"
        bfd    = try(int.bfd, null)
      } if try(int.bfd, null) != null],
      [for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        key    = format("%s/po%s", device.name, int.id)
        device = device.name
        id     = "po${int.id}"
        bfd    = try(int.bfd, null)
      } if try(int.bfd, null) != null],
    )
  ])
}

resource "nxos_bfd" "bfd" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].bfd, null) != null ||
  length([for int in local.bfd_interfaces : int if int.device == device.name]) > 0 }
  device               = each.key
  admin_state          = "enabled"
  instance_admin_state = "enabled"
  echo_interface       = try(local.device_config[each.key].bfd.echo_interface_type, null) != null ? "${local.intf_prefix_map[try(local.device_config[each.key].bfd.echo_interface_type)]}${try(local.device_config[each.key].bfd.echo_interface_id, "")}" : null
  hardware_offload     = try(local.device_config[each.key].bfd.hardware_offload, null) == null ? null : try(local.device_config[each.key].bfd.hardware_offload) ? "enable" : "disable"
  slow_interval        = try(local.device_config[each.key].bfd.slow_timer, null)
  startup_interval     = try(local.device_config[each.key].bfd.startup_timer, null)

  interfaces = { for int in local.bfd_interfaces : int.id => {
    control = join(",", sort(compact([
      try(int.bfd.optimize_subinterface, false) ? "opt-subif" : "",
      try(int.bfd.per_link, false) ? "pc-per-link" : "",
    ])))
    echo_admin_state       = try(int.bfd.echo, null) == null ? null : (try(int.bfd.echo) ? "enabled" : "disabled")
    source_ip              = try(int.bfd.source_ip, null)
    track_member_link      = try(int.bfd.track_member_link, null) == null ? null : try(int.bfd.track_member_link) ? "enable" : "disable"
    vpc_watch              = try(int.bfd.vpc_watch, null) == null ? null : try(int.bfd.vpc_watch) ? "enable" : "disable"
    detect_multiplier      = try(int.bfd.multiplier, null)
    echo_receive_interval  = try(int.bfd.echo_rx_interval, null)
    min_receive_interval   = try(int.bfd.min_rx, null)
    min_transmit_interval  = try(int.bfd.interval, null)
    authentication_interop = try(int.bfd.authentication_interop, null) == null ? null : try(int.bfd.authentication_interop) ? "enable" : "disable"
    authentication_key     = try(int.bfd.authentication_key, null)
    authentication_key_id  = try(int.bfd.authentication_key_id, null)
    authentication_type    = try(int.bfd.authentication_type, null)
  } if int.device == each.key }

  depends_on = [
    nxos_feature.feature,
    nxos_physical_interface.physical_interface,
    nxos_svi_interface.svi_interface,
    nxos_loopback_interface.loopback_interface,
    nxos_port_channel_interface.port_channel_interface,
  ]
}
