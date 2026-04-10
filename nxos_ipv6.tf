locals {
  # Group IPv6 routes by device/vrf for the nxos_ipv6 vrfs nested map
  ipv6_routes_by_device_vrf = {
    for entry in flatten([
      for device in local.devices : [
        for route in try(local.device_config[device.name].routing.ipv6_routes, []) : {
          device = device.name
          vrf    = try(route.vrf, "default")
          route  = route
        }
      ]
    ]) : "${entry.device}/${entry.vrf}" => entry...
  }

  # Collect all IPv6 interfaces across all interface types as a flat list
  ipv6_interfaces = flatten([
    for device in local.devices : concat(
      # Ethernets (L3 only)
      [for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        device                                   = device.name
        vrf                                      = try(int.vrf, "default")
        id                                       = "eth${int.id}"
        ipv6_address_autoconfig                  = try(int.ipv6.address_autoconfig, null)
        ipv6_nd_default_route                    = try(int.ipv6.nd_default_route, null)
        ipv6_forward                             = try(int.ipv6.forward, null)
        ipv6_link_local_use_bia                  = try(int.ipv6.link_local_use_bia, null)
        ipv6_address_use_link_local_only         = try(int.ipv6.address_use_link_local_only, null)
        ipv6_verify_unicast_source_reachable_via = try(int.ipv6.verify_unicast_source_reachable_via, null)
        ipv6_address_link_local                  = try(int.ipv6.address_link_local, null)
        ipv6_addresses                           = try(int.ipv6.addresses, [])
        } if !try(int.switchport.enabled, true) && try(int.channel_group, null) == null
      ],
      # Loopbacks
      [for int in try(local.device_config[device.name].interfaces.loopbacks, []) : {
        device                                   = device.name
        vrf                                      = try(int.vrf, "default")
        id                                       = "lo${int.id}"
        ipv6_address_autoconfig                  = try(int.ipv6.address_autoconfig, null)
        ipv6_nd_default_route                    = try(int.ipv6.nd_default_route, null)
        ipv6_forward                             = try(int.ipv6.forward, null)
        ipv6_link_local_use_bia                  = try(int.ipv6.link_local_use_bia, null)
        ipv6_address_use_link_local_only         = try(int.ipv6.address_use_link_local_only, null)
        ipv6_verify_unicast_source_reachable_via = try(int.ipv6.verify_unicast_source_reachable_via, null)
        ipv6_address_link_local                  = try(int.ipv6.address_link_local, null)
        ipv6_addresses                           = try(int.ipv6.addresses, [])
      }],
      # SVIs
      [for int in try(local.device_config[device.name].interfaces.vlans, []) : {
        device                                   = device.name
        vrf                                      = try(int.vrf, "default")
        id                                       = "vlan${int.id}"
        ipv6_address_autoconfig                  = try(int.ipv6.address_autoconfig, null)
        ipv6_nd_default_route                    = try(int.ipv6.nd_default_route, null)
        ipv6_forward                             = try(int.ipv6.forward, null)
        ipv6_link_local_use_bia                  = try(int.ipv6.link_local_use_bia, null)
        ipv6_address_use_link_local_only         = try(int.ipv6.address_use_link_local_only, null)
        ipv6_verify_unicast_source_reachable_via = try(int.ipv6.verify_unicast_source_reachable_via, null)
        ipv6_address_link_local                  = try(int.ipv6.address_link_local, null)
        ipv6_addresses                           = try(int.ipv6.addresses, [])
      }],
      # Port channels (L3 only)
      [for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        device                                   = device.name
        vrf                                      = try(int.vrf, "default")
        id                                       = "po${int.id}"
        ipv6_address_autoconfig                  = try(int.ipv6.address_autoconfig, null)
        ipv6_nd_default_route                    = try(int.ipv6.nd_default_route, null)
        ipv6_forward                             = try(int.ipv6.forward, null)
        ipv6_link_local_use_bia                  = try(int.ipv6.link_local_use_bia, null)
        ipv6_address_use_link_local_only         = try(int.ipv6.address_use_link_local_only, null)
        ipv6_verify_unicast_source_reachable_via = try(int.ipv6.verify_unicast_source_reachable_via, null)
        ipv6_address_link_local                  = try(int.ipv6.address_link_local, null)
        ipv6_addresses                           = try(int.ipv6.addresses, [])
        } if !try(int.switchport.enabled, true)
      ],
    )
  ])
}

resource "nxos_ipv6" "ipv6" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].system.ipv6_routing, null) != null ||
    try(local.device_config[device.name].system.ipv6_access_list_match_local_traffic, null) != null ||
    try(local.device_config[device.name].nd.drop_nd_fragments, null) != null ||
    try(local.device_config[device.name].nd.queue_packets, null) != null ||
    try(local.device_config[device.name].nd.allow_static_neighbor_outside_subnet, null) != null ||
    try(local.device_config[device.name].nd.switch_packets, null) != null ||
    length(try(local.device_config[device.name].vrfs, [])) > 0 ||
    length(try(local.device_config[device.name].routing.ipv6_routes, [])) > 0 ||
  length([for int in local.ipv6_interfaces : int if int.device == device.name]) > 0 }
  device = each.key

  access_list_match_local        = try(local.device_config[each.key].system.ipv6_access_list_match_local_traffic, null) != null ? (try(local.device_config[each.key].system.ipv6_access_list_match_local_traffic) ? "enabled" : "disabled") : null
  admin_state                    = try(local.device_config[each.key].system.ipv6_routing, null) != null ? (try(local.device_config[each.key].system.ipv6_routing) ? "enabled" : "disabled") : null
  drop_nd_fragments              = try(local.device_config[each.key].nd.drop_nd_fragments, null) != null ? (try(local.device_config[each.key].nd.drop_nd_fragments) ? "enabled" : "disabled") : null
  queue_packets                  = try(local.device_config[each.key].nd.queue_packets, null) != null ? (try(local.device_config[each.key].nd.queue_packets) ? "enabled" : "disabled") : null
  static_neighbor_outside_subnet = try(local.device_config[each.key].nd.allow_static_neighbor_outside_subnet, null) != null ? (try(local.device_config[each.key].nd.allow_static_neighbor_outside_subnet) ? "enabled" : "disabled") : null
  switch_packets                 = try(local.device_config[each.key].nd.switch_packets, null)

  vrfs = merge(
    # "default" VRF
    {
      "default" = {
        static_routes = { for route in try(local.ipv6_routes_by_device_vrf["${each.key}/default"], []) : route.route.prefix => {
          preference = try(route.route.preference, null)
          tag        = try(route.route.tag, null)

          next_hops = { for nh in try(route.route.next_hops, []) : "${try(nh.interface_type, null) != null ? "${local.intf_prefix_map[try(nh.interface_type)]}${try(nh.interface_id, "")}" : "unspecified"};${try(nh.address, "::")};${try(nh.vrf, "default")}" => {
            object     = try(nh.track, null)
            preference = try(nh.preference, null)
            tag        = try(nh.tag, null)
            name       = try(nh.name, null)
          } }
        } }

        interfaces = { for int in local.ipv6_interfaces : int.id => {
          auto_configuration         = int.ipv6_address_autoconfig != null ? (int.ipv6_address_autoconfig ? "enabled" : "disabled") : null
          default_route              = int.ipv6_nd_default_route != null ? (int.ipv6_nd_default_route ? "enabled" : "disabled") : null
          forward                    = int.ipv6_forward != null ? (int.ipv6_forward ? "enabled" : "disabled") : null
          link_local_address_use_bia = int.ipv6_link_local_use_bia != null ? (int.ipv6_link_local_use_bia ? "enabled" : "disabled") : null
          use_link_local_address     = int.ipv6_address_use_link_local_only != null ? (int.ipv6_address_use_link_local_only ? "enabled" : "disabled") : null
          urpf                       = int.ipv6_verify_unicast_source_reachable_via
          link_local_address         = int.ipv6_address_link_local

          addresses = { for addr in int.ipv6_addresses : addr.address => {
            type       = try(addr.type, null)
            tag        = try(addr.tag, null)
            control    = try(addr.eui64, false) ? "eui64" : null
            preference = try(addr.route_preference, null)
          } }
        } if int.device == each.key && int.vrf == "default" }
      }
    },
    # VRFs from configuration.vrfs[]
    { for vrf in try(local.device_config[each.key].vrfs, []) : vrf.name => {
      static_routes = { for route in try(local.ipv6_routes_by_device_vrf["${each.key}/${vrf.name}"], []) : route.route.prefix => {
        preference = try(route.route.preference, null)
        tag        = try(route.route.tag, null)

        next_hops = { for nh in try(route.route.next_hops, []) : "${try(nh.interface_type, null) != null ? "${local.intf_prefix_map[try(nh.interface_type)]}${try(nh.interface_id, "")}" : "unspecified"};${try(nh.address, "::")};${try(nh.vrf, "default")}" => {
          object     = try(nh.track, null)
          preference = try(nh.preference, null)
          tag        = try(nh.tag, null)
          name       = try(nh.name, null)
        } }
      } }

      interfaces = { for int in local.ipv6_interfaces : int.id => {
        auto_configuration         = int.ipv6_address_autoconfig != null ? (int.ipv6_address_autoconfig ? "enabled" : "disabled") : null
        default_route              = int.ipv6_nd_default_route != null ? (int.ipv6_nd_default_route ? "enabled" : "disabled") : null
        forward                    = int.ipv6_forward != null ? (int.ipv6_forward ? "enabled" : "disabled") : null
        link_local_address_use_bia = int.ipv6_link_local_use_bia != null ? (int.ipv6_link_local_use_bia ? "enabled" : "disabled") : null
        use_link_local_address     = int.ipv6_address_use_link_local_only != null ? (int.ipv6_address_use_link_local_only ? "enabled" : "disabled") : null
        urpf                       = int.ipv6_verify_unicast_source_reachable_via
        link_local_address         = int.ipv6_address_link_local

        addresses = { for addr in int.ipv6_addresses : addr.address => {
          type       = try(addr.type, null)
          tag        = try(addr.tag, null)
          control    = try(addr.eui64, false) ? "eui64" : null
          preference = try(addr.route_preference, null)
        } }
      } if int.device == each.key && int.vrf == vrf.name }
    } }
  )

  depends_on = [
    nxos_feature.feature,
    nxos_loopback_interface.loopback_interface,
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
    nxos_subinterface.subinterface,
    nxos_svi_interface.svi_interface,
    nxos_vrf.vrf,
  ]
}
