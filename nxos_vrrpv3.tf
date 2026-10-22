locals {
  vrrpv3_interfaces_map = { for device in local.devices : device.name =>
    { for int in local.vrrpv3_interfaces : int.id => {
      delay_minimum = try(int.fhrp_delay_minimum, null)
      reload_delay  = try(int.fhrp_delay_reload, null)

      groups = length(int.vrrpv3_groups) > 0 ? { for group in int.vrrpv3_groups : "${group.id};${group.address_family}" => {
        admin_state               = try(group.shutdown, null) == null ? null : (try(group.shutdown) ? "disabled" : "enabled")
        advertisement_interval    = try(group.timers_advertise, null)
        primary_address           = try(group.address, null)
        match_address             = try(group.match_address, null) == null ? null : (try(group.match_address) ? "enabled" : "disabled")
        description               = try(group.description, null)
        preempt                   = try(group.preempt, null) == null ? null : (try(group.preempt) ? "enabled" : "disabled")
        preempt_delay_minimum     = try(group.preempt_delay_minimum, null)
        priority                  = try(group.priority, null)
        vrrpv2_compatibility_mode = try(group.vrrpv2, null) == null ? null : (try(group.vrrpv2) ? "enabled" : "disabled")
        secondary_addresses       = length(try(group.secondary_addresses, [])) > 0 ? { for address in try(group.secondary_addresses, []) : address => {} } : null
        tracked_objects = length(try(group.object_tracks, [])) > 0 ? { for track in try(group.object_tracks, []) : track.id => {
          decrement_priority = try(track.decrement, null)
        } } : null
        vrrs_leaders = length(try(group.vrrs_leaders, [])) > 0 ? { for tag in try(group.vrrs_leaders, []) : tag => {} } : null
      } } : null

      vrrs_pathways = length(int.vrrs_pathways) > 0 ? { for pathway in int.vrrs_pathways : pathway.name => {
        admin_state                = try(pathway.shutdown, null) == null ? null : (try(pathway.shutdown) ? "disabled" : "enabled")
        description                = try(pathway.description, null)
        mac_address                = try(pathway.mac_address, null)
        mac_advertisement_interval = try(pathway.mac_advert_interval, null)
        addresses                  = length(try(pathway.addresses, [])) > 0 ? { for address in try(pathway.addresses, []) : address => {} } : null
      } } : null
    } if int.device == device.name }
  }
  vrrpv3_interfaces = flatten([
    for device in local.devices : concat(
      [for int in try(local.device_config[device.name].interfaces.vlans, []) : {
        key                = format("%s/vlan%s", device.name, int.id)
        device             = device.name
        id                 = "vlan${int.id}"
        fhrp_delay_minimum = try(int.fhrp_delay_minimum, null)
        fhrp_delay_reload  = try(int.fhrp_delay_reload, null)
        vrrpv3_groups      = try(int.vrrpv3_groups, [])
        vrrs_pathways      = try(int.vrrs_pathways, [])
      } if length(try(int.vrrpv3_groups, [])) > 0 || length(try(int.vrrs_pathways, [])) > 0 || try(int.fhrp_delay_minimum, null) != null || try(int.fhrp_delay_reload, null) != null],
      [for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        key                = format("%s/eth%s", device.name, int.id)
        device             = device.name
        id                 = "eth${int.id}"
        fhrp_delay_minimum = try(int.fhrp_delay_minimum, null)
        fhrp_delay_reload  = try(int.fhrp_delay_reload, null)
        vrrpv3_groups      = try(int.vrrpv3_groups, [])
        vrrs_pathways      = try(int.vrrs_pathways, [])
      } if length(try(int.vrrpv3_groups, [])) > 0 || length(try(int.vrrs_pathways, [])) > 0 || try(int.fhrp_delay_minimum, null) != null || try(int.fhrp_delay_reload, null) != null],
      [for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        key                = format("%s/po%s", device.name, int.id)
        device             = device.name
        id                 = "po${int.id}"
        fhrp_delay_minimum = try(int.fhrp_delay_minimum, null)
        fhrp_delay_reload  = try(int.fhrp_delay_reload, null)
        vrrpv3_groups      = try(int.vrrpv3_groups, [])
        vrrs_pathways      = try(int.vrrs_pathways, [])
      } if length(try(int.vrrpv3_groups, [])) > 0 || length(try(int.vrrs_pathways, [])) > 0 || try(int.fhrp_delay_minimum, null) != null || try(int.fhrp_delay_reload, null) != null],
      flatten([for eth in try(local.device_config[device.name].interfaces.ethernets, []) :
        [for sub in try(eth.subinterfaces, []) : {
          key                = format("%s/eth%s.%s", device.name, eth.id, sub.id)
          device             = device.name
          id                 = "eth${eth.id}.${sub.id}"
          fhrp_delay_minimum = try(sub.fhrp_delay_minimum, null)
          fhrp_delay_reload  = try(sub.fhrp_delay_reload, null)
          vrrpv3_groups      = try(sub.vrrpv3_groups, [])
          vrrs_pathways      = try(sub.vrrs_pathways, [])
        } if length(try(sub.vrrpv3_groups, [])) > 0 || length(try(sub.vrrs_pathways, [])) > 0 || try(sub.fhrp_delay_minimum, null) != null || try(sub.fhrp_delay_reload, null) != null]
      ]),
      flatten([for pc in try(local.device_config[device.name].interfaces.port_channels, []) :
        [for sub in try(pc.subinterfaces, []) : {
          key                = format("%s/po%s.%s", device.name, pc.id, sub.id)
          device             = device.name
          id                 = "po${pc.id}.${sub.id}"
          fhrp_delay_minimum = try(sub.fhrp_delay_minimum, null)
          fhrp_delay_reload  = try(sub.fhrp_delay_reload, null)
          vrrpv3_groups      = try(sub.vrrpv3_groups, [])
          vrrs_pathways      = try(sub.vrrs_pathways, [])
        } if length(try(sub.vrrpv3_groups, [])) > 0 || length(try(sub.vrrs_pathways, [])) > 0 || try(sub.fhrp_delay_minimum, null) != null || try(sub.fhrp_delay_reload, null) != null]
      ]),
    )
  ])
}

resource "nxos_vrrpv3" "vrrpv3" {
  for_each = { for device in local.devices : device.name => device
  if length(local.vrrpv3_interfaces_map[device.name]) > 0 }
  device = each.key

  interfaces = local.vrrpv3_interfaces_map[each.key]

  depends_on = [
    nxos_cli.cli_pre_9,
    nxos_feature.feature,
    nxos_physical_interface.physical_interface,
    nxos_svi_interface.svi_interface,
    nxos_port_channel_interface.port_channel_interface,
    nxos_subinterface.subinterface,
    nxos_ipv4.ipv4,
    nxos_ipv6.ipv6,
    nxos_track.track,
  ]
}
