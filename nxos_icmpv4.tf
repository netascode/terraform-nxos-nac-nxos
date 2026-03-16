locals {
  icmpv4_interfaces = flatten([
    for device in local.devices : concat(
      [for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        device                = device.name
        vrf                   = try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.ethernets.vrf, "default")
        id                    = "eth${int.id}"
        ipv4_redirect         = try(int.ipv4_redirect, local.defaults.nxos.devices.configuration.interfaces.ethernets.ipv4_redirect, null)
        ipv4_unreachable      = try(int.ipv4_unreachable, local.defaults.nxos.devices.configuration.interfaces.ethernets.ipv4_unreachable, null)
        ipv4_port_unreachable = try(int.ipv4_port_unreachable, local.defaults.nxos.devices.configuration.interfaces.ethernets.ipv4_port_unreachable, null)
        } if try(int.ipv4_redirect, local.defaults.nxos.devices.configuration.interfaces.ethernets.ipv4_redirect, null) != null ||
        try(int.ipv4_unreachable, local.defaults.nxos.devices.configuration.interfaces.ethernets.ipv4_unreachable, null) != null ||
        try(int.ipv4_port_unreachable, local.defaults.nxos.devices.configuration.interfaces.ethernets.ipv4_port_unreachable, null) != null
      ],
      [for int in try(local.device_config[device.name].interfaces.loopbacks, []) : {
        device                = device.name
        vrf                   = try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.loopbacks.vrf, "default")
        id                    = "lo${int.id}"
        ipv4_redirect         = try(int.ipv4_redirect, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ipv4_redirect, null)
        ipv4_unreachable      = try(int.ipv4_unreachable, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ipv4_unreachable, null)
        ipv4_port_unreachable = try(int.ipv4_port_unreachable, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ipv4_port_unreachable, null)
        } if try(int.ipv4_redirect, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ipv4_redirect, null) != null ||
        try(int.ipv4_unreachable, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ipv4_unreachable, null) != null ||
        try(int.ipv4_port_unreachable, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ipv4_port_unreachable, null) != null
      ],
      [for int in try(local.device_config[device.name].interfaces.vlans, []) : {
        device                = device.name
        vrf                   = try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.vlans.vrf, "default")
        id                    = "vlan${int.id}"
        ipv4_redirect         = try(int.ipv4_redirect, local.defaults.nxos.devices.configuration.interfaces.vlans.ipv4_redirect, null)
        ipv4_unreachable      = try(int.ipv4_unreachable, local.defaults.nxos.devices.configuration.interfaces.vlans.ipv4_unreachable, null)
        ipv4_port_unreachable = try(int.ipv4_port_unreachable, local.defaults.nxos.devices.configuration.interfaces.vlans.ipv4_port_unreachable, null)
        } if try(int.ipv4_redirect, local.defaults.nxos.devices.configuration.interfaces.vlans.ipv4_redirect, null) != null ||
        try(int.ipv4_unreachable, local.defaults.nxos.devices.configuration.interfaces.vlans.ipv4_unreachable, null) != null ||
        try(int.ipv4_port_unreachable, local.defaults.nxos.devices.configuration.interfaces.vlans.ipv4_port_unreachable, null) != null
      ],
      [for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        device                = device.name
        vrf                   = try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.port_channels.vrf, "default")
        id                    = "po${int.id}"
        ipv4_redirect         = try(int.ipv4_redirect, local.defaults.nxos.devices.configuration.interfaces.port_channels.ipv4_redirect, null)
        ipv4_unreachable      = try(int.ipv4_unreachable, local.defaults.nxos.devices.configuration.interfaces.port_channels.ipv4_unreachable, null)
        ipv4_port_unreachable = try(int.ipv4_port_unreachable, local.defaults.nxos.devices.configuration.interfaces.port_channels.ipv4_port_unreachable, null)
        } if try(int.ipv4_redirect, local.defaults.nxos.devices.configuration.interfaces.port_channels.ipv4_redirect, null) != null ||
        try(int.ipv4_unreachable, local.defaults.nxos.devices.configuration.interfaces.port_channels.ipv4_unreachable, null) != null ||
        try(int.ipv4_port_unreachable, local.defaults.nxos.devices.configuration.interfaces.port_channels.ipv4_port_unreachable, null) != null
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
        try(int.ipv4_port_unreachable, false) ? "port-unreachable" : "",
        try(int.ipv4_redirect, false) ? "redirect" : "",
        try(int.ipv4_unreachable, false) ? "unreachable" : "",
      ])))
    } if int.device == each.key && int.vrf == entry.vrf }
  } if entry.device == each.key }
}
