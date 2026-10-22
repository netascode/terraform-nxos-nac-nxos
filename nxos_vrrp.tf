locals {
  vrrp_interfaces_map = { for device in local.devices : device.name =>
    { for int in local.vrrp_interfaces : int.id => {
      groups = { for group in int.vrrp_groups : group.id => {
        admin_state                = try(group.shutdown, null) == null ? null : (try(group.shutdown) ? "disabled" : "enabled")
        advertisement_interval     = try(group.advertisement_interval, null)
        authentication_text        = try(group.authentication_text, null)
        authentication_type        = try(group.authentication_text, null) != null ? "simple" : null
        bfd_peer_address           = try(group.bfd, null)
        forwarding_lower_threshold = try(group.forwarding_threshold_lower, null)
        forwarding_upper_threshold = try(group.forwarding_threshold_upper, null)
        preempt                    = try(group.preempt, null) == null ? null : (try(group.preempt) ? "enabled" : "disabled")
        priority                   = try(group.priority, null)
        primary_address            = try(group.address, null)
        secondary_addresses        = length(try(group.secondary_addresses, [])) > 0 ? { for address in try(group.secondary_addresses, []) : address => {} } : null
        track_interface            = try(group.track_interface_type, null) != null ? "${local.intf_prefix_map[try(group.track_interface_type)]}${try(group.track_interface_id, "")}" : null
        track_priority             = try(group.track_interface_priority, null)
        tracked_objects = length(try(group.tracks, [])) > 0 ? { for track in try(group.tracks, []) : track.id => {
          decrement_priority = try(track.decrement, null)
        } } : null
      } }
    } if int.device == device.name }
  }
  vrrp_interfaces = flatten([
    for device in local.devices : concat(
      [for int in try(local.device_config[device.name].interfaces.vlans, []) : {
        key         = format("%s/vlan%s", device.name, int.id)
        device      = device.name
        id          = "vlan${int.id}"
        vrrp_groups = try(int.vrrp_groups, [])
      } if length(try(int.vrrp_groups, [])) > 0],
      [for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        key         = format("%s/eth%s", device.name, int.id)
        device      = device.name
        id          = "eth${int.id}"
        vrrp_groups = try(int.vrrp_groups, [])
      } if length(try(int.vrrp_groups, [])) > 0],
      [for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        key         = format("%s/po%s", device.name, int.id)
        device      = device.name
        id          = "po${int.id}"
        vrrp_groups = try(int.vrrp_groups, [])
      } if length(try(int.vrrp_groups, [])) > 0],
      flatten([for eth in try(local.device_config[device.name].interfaces.ethernets, []) :
        [for sub in try(eth.subinterfaces, []) : {
          key         = format("%s/eth%s.%s", device.name, eth.id, sub.id)
          device      = device.name
          id          = "eth${eth.id}.${sub.id}"
          vrrp_groups = try(sub.vrrp_groups, [])
        } if length(try(sub.vrrp_groups, [])) > 0]
      ]),
      flatten([for pc in try(local.device_config[device.name].interfaces.port_channels, []) :
        [for sub in try(pc.subinterfaces, []) : {
          key         = format("%s/po%s.%s", device.name, pc.id, sub.id)
          device      = device.name
          id          = "po${pc.id}.${sub.id}"
          vrrp_groups = try(sub.vrrp_groups, [])
        } if length(try(sub.vrrp_groups, [])) > 0]
      ]),
    )
  ])
}

resource "nxos_vrrp" "vrrp" {
  for_each = { for device in local.devices : device.name => device
  if length(local.vrrp_interfaces_map[device.name]) > 0 }
  device = each.key

  interfaces = local.vrrp_interfaces_map[each.key]

  depends_on = [
    nxos_cli.cli_pre_9,
    nxos_feature.feature,
    nxos_physical_interface.physical_interface,
    nxos_svi_interface.svi_interface,
    nxos_port_channel_interface.port_channel_interface,
    nxos_subinterface.subinterface,
    nxos_ipv4.ipv4,
    nxos_bfd.bfd,
    nxos_track.track,
  ]
}
