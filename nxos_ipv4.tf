locals {
  # Group routes by device/vrf for the nxos_ipv4 vrfs nested map
  ip_routes_by_device_vrf = {
    for entry in flatten([
      for device in local.devices : [
        for route in try(local.device_config[device.name].routing.ip_routes, []) : {
          device = device.name
          vrf    = try(route.vrf, "default")
          route  = route
        }
      ]
    ]) : "${entry.device}/${entry.vrf}" => entry...
  }

  # Collect all IPv4 interfaces across all interface types as a flat list
  ip_interfaces = flatten([
    for device in local.devices : concat(
      # Ethernets (L3 only)
      [for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        device                                 = device.name
        vrf                                    = try(int.vrf, "default")
        id                                     = "eth${int.id}"
        drop_glean                             = null
        forward                                = null
        unnumbered                             = try(int.ip.unnumbered, null)
        ip_verify_unicast_source_reachable_via = try(int.ip.verify_unicast_source_reachable_via, null)
        ip_directed_broadcast                  = try(int.ip.directed_broadcast, null)
        ip_directed_broadcast_acl              = try(int.ip.directed_broadcast_acl, null)
        ip_address                             = try(int.ip.address, null)
        ip_secondary_addresses                 = try(int.ip.secondary_addresses, [])
        } if !try(int.switchport.enabled, true) && try(int.channel_group, null) == null
      ],
      # Loopbacks
      [for int in try(local.device_config[device.name].interfaces.loopbacks, []) : {
        device                                 = device.name
        vrf                                    = try(int.vrf, "default")
        id                                     = "lo${int.id}"
        drop_glean                             = null
        forward                                = null
        unnumbered                             = null
        ip_verify_unicast_source_reachable_via = null
        ip_directed_broadcast                  = null
        ip_directed_broadcast_acl              = null
        ip_address                             = try(int.ip.address, null)
        ip_secondary_addresses                 = try(int.ip.secondary_addresses, [])
      }],
      # SVIs
      [for int in try(local.device_config[device.name].interfaces.vlans, []) : {
        device                                 = device.name
        vrf                                    = try(int.vrf, "default")
        id                                     = "vlan${int.id}"
        drop_glean                             = try(int.ip.drop_glean, null) != null ? (try(int.ip.drop_glean) ? "enabled" : "disabled") : null
        forward                                = try(int.ip.forward, null) != null ? (try(int.ip.forward) ? "enabled" : "disabled") : null
        unnumbered                             = null
        ip_verify_unicast_source_reachable_via = null
        ip_directed_broadcast                  = try(int.ip.directed_broadcast, null)
        ip_directed_broadcast_acl              = try(int.ip.directed_broadcast_acl, null)
        ip_address                             = try(int.ip.address, null)
        ip_secondary_addresses                 = try(int.ip.secondary_addresses, [])
      }],
      # Port channels (L3 only)
      [for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        device                                 = device.name
        vrf                                    = try(int.vrf, "default")
        id                                     = "po${int.id}"
        drop_glean                             = null
        forward                                = null
        unnumbered                             = try(int.ip.unnumbered, null)
        ip_verify_unicast_source_reachable_via = try(int.ip.verify_unicast_source_reachable_via, null)
        ip_directed_broadcast                  = try(int.ip.directed_broadcast, null)
        ip_directed_broadcast_acl              = try(int.ip.directed_broadcast_acl, null)
        ip_address                             = try(int.ip.address, null)
        ip_secondary_addresses                 = try(int.ip.secondary_addresses, [])
        } if !try(int.switchport.enabled, true)
      ],
      # Subinterfaces (ethernets)
      flatten([for int in try(local.device_config[device.name].interfaces.ethernets, []) :
        [for sub in try(int.subinterfaces, []) : {
          device                                 = device.name
          vrf                                    = try(sub.vrf, "default")
          id                                     = "eth${int.id}.${sub.id}"
          drop_glean                             = null
          forward                                = null
          unnumbered                             = try(sub.ip.unnumbered, null)
          ip_verify_unicast_source_reachable_via = try(sub.ip.verify_unicast_source_reachable_via, null)
          ip_directed_broadcast                  = try(sub.ip.directed_broadcast, null)
          ip_directed_broadcast_acl              = try(sub.ip.directed_broadcast_acl, null)
          ip_address                             = try(sub.ip.address, null)
          ip_secondary_addresses                 = try(sub.ip.secondary_addresses, [])
        }]
      ]),
      # Subinterfaces (port channels)
      flatten([for int in try(local.device_config[device.name].interfaces.port_channels, []) :
        [for sub in try(int.subinterfaces, []) : {
          device                                 = device.name
          vrf                                    = try(sub.vrf, "default")
          id                                     = "po${int.id}.${sub.id}"
          drop_glean                             = null
          forward                                = null
          unnumbered                             = try(sub.ip.unnumbered, null)
          ip_verify_unicast_source_reachable_via = try(sub.ip.verify_unicast_source_reachable_via, null)
          ip_directed_broadcast                  = try(sub.ip.directed_broadcast, null)
          ip_directed_broadcast_acl              = try(sub.ip.directed_broadcast_acl, null)
          ip_address                             = try(sub.ip.address, null)
          ip_secondary_addresses                 = try(sub.ip.secondary_addresses, [])
        }]
      ]),
      # Management interfaces
      [for int in try(local.device_config[device.name].interfaces.management, []) : {
        device                                 = device.name
        vrf                                    = "management"
        id                                     = "mgmt${int.id}"
        drop_glean                             = null
        forward                                = null
        unnumbered                             = null
        ip_verify_unicast_source_reachable_via = null
        ip_directed_broadcast                  = null
        ip_directed_broadcast_acl              = null
        ip_address                             = try(int.ip.address, null)
        ip_secondary_addresses                 = try(int.ip.secondary_addresses, [])
      } if try(int.ip, null) != null],
    )
  ])
}

resource "nxos_ipv4" "ipv4" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].system.ip_routing, null) != null ||
    try(local.device_config[device.name].system.ip_access_list_match_local_traffic, null) != null ||
    try(local.device_config[device.name].system.hardware_ecmp_hash_offset_concatenation, null) != null ||
    try(local.device_config[device.name].system.hardware_ecmp_hash_offset_value, null) != null ||
    try(local.device_config[device.name].system.hardware_ecmp_hash_polynomial, null) != null ||
    try(local.device_config[device.name].system.logging_level_ip, null) != null ||
    try(local.device_config[device.name].system.ip_redirect_syslog, null) != null ||
    try(local.device_config[device.name].system.ip_redirect_syslog_interval, null) != null ||
    try(local.device_config[device.name].system.ip_source_route, null) != null ||
    length(try(local.device_config[device.name].vrfs, [])) > 0 ||
    length(try(local.device_config[device.name].routing.ip_routes, [])) > 0 ||
  length([for int in local.ip_interfaces : int if int.device == device.name]) > 0 }
  device = each.key

  instance_admin_state                    = try(local.device_config[each.key].system.ip_routing, null) != null ? (try(local.device_config[each.key].system.ip_routing) ? "enabled" : "disabled") : null
  access_list_match_local                 = try(local.device_config[each.key].system.ip_access_list_match_local_traffic, null) != null ? (try(local.device_config[each.key].system.ip_access_list_match_local_traffic) ? "enabled" : "disabled") : null
  hardware_ecmp_hash_offset_concatenation = try(local.device_config[each.key].system.hardware_ecmp_hash_offset_concatenation, null) != null ? (try(local.device_config[each.key].system.hardware_ecmp_hash_offset_concatenation) ? "enabled" : "disabled") : null
  hardware_ecmp_hash_offset_value         = try(local.device_config[each.key].system.hardware_ecmp_hash_offset_value, null)
  hardware_ecmp_hash_polynomial           = try(local.device_config[each.key].system.hardware_ecmp_hash_polynomial, null) != null ? upper(try(local.device_config[each.key].system.hardware_ecmp_hash_polynomial)) : null
  logging_level                           = try(local.device_config[each.key].system.logging_level_ip, null)
  redirect_syslog                         = try(local.device_config[each.key].system.ip_redirect_syslog, null) != null ? (try(local.device_config[each.key].system.ip_redirect_syslog) ? "enabled" : "disabled") : null
  redirect_syslog_interval                = try(local.device_config[each.key].system.ip_redirect_syslog_interval, null)
  source_route                            = try(local.device_config[each.key].system.ip_source_route, null) != null ? (try(local.device_config[each.key].system.ip_source_route) ? "enabled" : "disabled") : null

  vrfs = merge(
    # "default" VRF
    {
      "default" = {
        auto_discard                 = null
        icmp_errors_source_interface = null

        static_routes = { for route in try(local.ip_routes_by_device_vrf["${each.key}/default"], []) : route.route.prefix => {
          control    = try(route.route.bfd, false) ? "bfd" : (try(route.route.pervasive, false) ? "pervasive" : null)
          preference = try(route.route.preference, null)
          tag        = try(route.route.tag, null)

          next_hops = { for nh in try(route.route.next_hops, []) : "${try(nh.interface_type, null) != null ? "${local.intf_prefix_map[try(nh.interface_type)]}${try(nh.interface_id, "")}" : "unspecified"};${try(nh.address, "0.0.0.0")};${try(nh.vrf, "default")}" => {
            object     = try(nh.track, null)
            preference = try(nh.preference, null)
            tag        = try(nh.tag, null)
            name       = try(nh.name, null)
          } }
        } }

        interfaces = { for int in local.ip_interfaces : int.id => {
          drop_glean             = int.drop_glean
          forward                = int.forward
          unnumbered             = int.unnumbered
          urpf                   = int.ip_verify_unicast_source_reachable_via
          directed_broadcast     = int.ip_directed_broadcast != null ? (int.ip_directed_broadcast ? "enabled" : "disabled") : null
          directed_broadcast_acl = int.ip_directed_broadcast_acl

          addresses = merge(
            int.ip_address != null ? { (int.ip_address) = { type = "primary" } } : {},
            { for ip in int.ip_secondary_addresses : ip => { type = "secondary" } }
          )
        } if int.device == each.key && int.vrf == "default" }
      }
    },
    # VRFs from configuration.vrfs[]
    { for vrf in try(local.device_config[each.key].vrfs, []) : vrf.name => {
      auto_discard                 = try(vrf.auto_discard, null) != null ? (try(vrf.auto_discard) ? "enabled" : "disabled") : null
      icmp_errors_source_interface = try(vrf.icmp_errors_source_interface_type, null) != null ? "${local.intf_prefix_map[try(vrf.icmp_errors_source_interface_type)]}${try(vrf.icmp_errors_source_interface_id, "")}" : null

      static_routes = { for route in try(local.ip_routes_by_device_vrf["${each.key}/${vrf.name}"], []) : route.route.prefix => {
        control    = try(route.route.bfd, false) ? "bfd" : (try(route.route.pervasive, false) ? "pervasive" : null)
        preference = try(route.route.preference, null)
        tag        = try(route.route.tag, null)

        next_hops = { for nh in try(route.route.next_hops, []) : "${try(nh.interface_type, null) != null ? "${local.intf_prefix_map[try(nh.interface_type)]}${try(nh.interface_id, "")}" : "unspecified"};${try(nh.address, "0.0.0.0")};${try(nh.vrf, "default")}" => {
          object     = try(nh.track, null)
          preference = try(nh.preference, null)
          tag        = try(nh.tag, null)
          name       = try(nh.name, null)
        } }
      } }

      interfaces = { for int in local.ip_interfaces : int.id => {
        drop_glean             = int.drop_glean
        forward                = int.forward
        unnumbered             = int.unnumbered
        urpf                   = int.ip_verify_unicast_source_reachable_via
        directed_broadcast     = int.ip_directed_broadcast != null ? (int.ip_directed_broadcast ? "enabled" : "disabled") : null
        directed_broadcast_acl = int.ip_directed_broadcast_acl

        addresses = merge(
          int.ip_address != null ? { (int.ip_address) = { type = "primary" } } : {},
          { for ip in int.ip_secondary_addresses : ip => { type = "secondary" } }
        )
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
