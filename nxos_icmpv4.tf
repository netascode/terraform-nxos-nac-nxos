locals {
  icmpv4_interfaces = flatten([
    for device in local.devices : concat(
      [for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        device              = device.name
        vrf                 = try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.ethernets.vrf, "default")
        id                  = "eth${int.id}"
        ip_redirects        = try(int.ip_redirects, local.defaults.nxos.devices.configuration.interfaces.ethernets.ip_redirects, null)
        ip_unreachables     = try(int.ip_unreachables, local.defaults.nxos.devices.configuration.interfaces.ethernets.ip_unreachables, null)
        ip_port_unreachable = try(int.ip_port_unreachable, local.defaults.nxos.devices.configuration.interfaces.ethernets.ip_port_unreachable, null)
        is_svi_with_vpc     = false
        } if try(int.ip_redirects, local.defaults.nxos.devices.configuration.interfaces.ethernets.ip_redirects, null) != null ||
        try(int.ip_unreachables, local.defaults.nxos.devices.configuration.interfaces.ethernets.ip_unreachables, null) != null ||
        try(int.ip_port_unreachable, local.defaults.nxos.devices.configuration.interfaces.ethernets.ip_port_unreachable, null) != null
      ],
      [for int in try(local.device_config[device.name].interfaces.loopbacks, []) : {
        device              = device.name
        vrf                 = try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.loopbacks.vrf, "default")
        id                  = "lo${int.id}"
        ip_redirects        = try(int.ip_redirects, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ip_redirects, null)
        ip_unreachables     = try(int.ip_unreachables, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ip_unreachables, null)
        ip_port_unreachable = try(int.ip_port_unreachable, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ip_port_unreachable, null)
        is_svi_with_vpc     = false
        } if try(int.ip_redirects, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ip_redirects, null) != null ||
        try(int.ip_unreachables, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ip_unreachables, null) != null ||
        try(int.ip_port_unreachable, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ip_port_unreachable, null) != null
      ],
      [for int in try(local.device_config[device.name].interfaces.vlans, []) : {
        device              = device.name
        vrf                 = try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.vlans.vrf, "default")
        id                  = "vlan${int.id}"
        ip_redirects        = try(int.ip_redirects, local.defaults.nxos.devices.configuration.interfaces.vlans.ip_redirects, null)
        ip_unreachables     = try(int.ip_unreachables, local.defaults.nxos.devices.configuration.interfaces.vlans.ip_unreachables, null)
        ip_port_unreachable = try(int.ip_port_unreachable, local.defaults.nxos.devices.configuration.interfaces.vlans.ip_port_unreachable, null)
        is_svi_with_vpc     = try(local.device_config[device.name].vpc.domain_id, null) != null
        } if try(int.ip_redirects, local.defaults.nxos.devices.configuration.interfaces.vlans.ip_redirects, null) != null ||
        try(int.ip_unreachables, local.defaults.nxos.devices.configuration.interfaces.vlans.ip_unreachables, null) != null ||
        try(int.ip_port_unreachable, local.defaults.nxos.devices.configuration.interfaces.vlans.ip_port_unreachable, null) != null
      ],
      [for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        device              = device.name
        vrf                 = try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.port_channels.vrf, "default")
        id                  = "po${int.id}"
        ip_redirects        = try(int.ip_redirects, local.defaults.nxos.devices.configuration.interfaces.port_channels.ip_redirects, null)
        ip_unreachables     = try(int.ip_unreachables, local.defaults.nxos.devices.configuration.interfaces.port_channels.ip_unreachables, null)
        ip_port_unreachable = try(int.ip_port_unreachable, local.defaults.nxos.devices.configuration.interfaces.port_channels.ip_port_unreachable, null)
        is_svi_with_vpc     = false
        } if try(int.ip_redirects, local.defaults.nxos.devices.configuration.interfaces.port_channels.ip_redirects, null) != null ||
        try(int.ip_unreachables, local.defaults.nxos.devices.configuration.interfaces.port_channels.ip_unreachables, null) != null ||
        try(int.ip_port_unreachable, local.defaults.nxos.devices.configuration.interfaces.port_channels.ip_port_unreachable, null) != null
      ],
    )
  ])
  icmpv4_vrfs = { for entry in distinct([for int in local.icmpv4_interfaces : { device = int.device, vrf = int.vrf }]) :
    "${entry.device}/${entry.vrf}" => entry
  }
}

resource "nxos_icmpv4" "icmpv4" {
  for_each = { for device in local.devices : device.name => device
  if length([for int in local.icmpv4_interfaces : int if int.device == device.name]) > 0 }
  device               = each.key
  admin_state          = "enabled"
  instance_admin_state = "enabled"
  control              = ""
  vrfs = { for key, entry in local.icmpv4_vrfs : entry.vrf => {
    interfaces = { for int in local.icmpv4_interfaces : int.id => {
      control = join(",", sort(compact([
        try(int.ip_port_unreachable, false) == true ? "port-unreachable" : "",
        try(int.ip_redirects, false) == true && !int.is_svi_with_vpc ? "redirect" : "",
        try(int.ip_unreachables, false) == true ? "unreachable" : "",
      ])))
    } if int.device == each.key && int.vrf == entry.vrf }
  } if entry.device == each.key }

  depends_on = [
    nxos_feature.feature,
    nxos_loopback_interface.loopback_interface,
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
    nxos_svi_interface.svi_interface,
    nxos_vrf.vrf,
  ]
}
