locals {
  icmpv6_interfaces = flatten([
    for device in local.devices : concat(
      [for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        device       = device.name
        id           = "eth${int.id}"
        redirects    = try(int.ipv6.redirects, null)
        unreachables = try(int.ipv6.unreachables, null)
        } if try(int.ipv6.redirects, null) != null ||
        try(int.ipv6.unreachables, null) != null
      ],
      [for int in try(local.device_config[device.name].interfaces.loopbacks, []) : {
        device       = device.name
        id           = "lo${int.id}"
        redirects    = try(int.ipv6.redirects, null)
        unreachables = try(int.ipv6.unreachables, null)
        } if try(int.ipv6.redirects, null) != null ||
        try(int.ipv6.unreachables, null) != null
      ],
      [for int in try(local.device_config[device.name].interfaces.vlans, []) : {
        device       = device.name
        id           = "vlan${int.id}"
        redirects    = try(int.ipv6.redirects, null)
        unreachables = try(int.ipv6.unreachables, null)
        } if try(int.ipv6.redirects, null) != null ||
        try(int.ipv6.unreachables, null) != null
      ],
      [for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        device       = device.name
        id           = "po${int.id}"
        redirects    = try(int.ipv6.redirects, null)
        unreachables = try(int.ipv6.unreachables, null)
        } if try(int.ipv6.redirects, null) != null ||
        try(int.ipv6.unreachables, null) != null
      ],
    )
  ])
}

resource "nxos_icmpv6" "icmpv6" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].system.ipv6_adjacency_stale_timer, null) != null ||
    try(local.device_config[device.name].system.ipv6_adjacency_stale_timer_icmp, null) != null ||
    try(local.device_config[device.name].system.ipv6_redirect_syslog, null) != null ||
    try(local.device_config[device.name].system.ipv6_redirect_syslog_interval, null) != null ||
  length([for int in local.icmpv6_interfaces : int if int.device == device.name]) > 0 }
  device               = each.key
  admin_state          = "enabled"
  instance_admin_state = "enabled"
  control              = ""

  adjacency_stale_timer      = try(local.device_config[each.key].system.ipv6_adjacency_stale_timer, null)
  adjacency_stale_timer_icmp = try(local.device_config[each.key].system.ipv6_adjacency_stale_timer_icmp, null) == null ? null : (try(local.device_config[each.key].system.ipv6_adjacency_stale_timer_icmp) ? "enabled" : "disabled")
  redirect_syslog            = try(local.device_config[each.key].system.ipv6_redirect_syslog, null) == null ? null : (try(local.device_config[each.key].system.ipv6_redirect_syslog) ? "enabled" : "disabled")
  redirect_syslog_interval   = try(local.device_config[each.key].system.ipv6_redirect_syslog_interval, null)

  interfaces = { for int in local.icmpv6_interfaces : int.id => {
    control = join(",", sort(compact([
      try(int.redirects, false) == true ? "redirect" : "",
      try(int.unreachables, false) == true ? "unreachables" : "",
    ])))
  } if int.device == each.key }

  depends_on = [
    nxos_feature.feature,
    nxos_loopback_interface.loopback_interface,
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
    nxos_svi_interface.svi_interface,
    nxos_vrf.vrf,
  ]
}
