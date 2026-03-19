locals {
  # Group static routes by device/vrf for the nxos_ipv4 vrfs nested map
  ip_static_routes_by_device_vrf = {
    for entry in flatten([
      for device in local.devices : [
        for route in try(local.device_config[device.name].routing.ip_static_routes, []) : {
          device = device.name
          vrf    = route.vrf
          route  = route
        }
      ]
    ]) : "${entry.device}/${entry.vrf}" => entry...
  }

  # Collect all IPv4 interfaces across all interface types as a flat list
  ip_interfaces = flatten([
    for device in local.devices : concat(
      # Ethernets (layer3 only)
      [for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        device                 = device.name
        vrf                    = try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.ethernets.vrf, "default")
        id                     = "eth${int.id}"
        drop_glean             = null
        forward                = null
        unnumbered             = try(int.ip_unnumbered, local.defaults.nxos.devices.configuration.interfaces.ethernets.ip_unnumbered, null)
        urpf                   = try(int.urpf, local.defaults.nxos.devices.configuration.interfaces.ethernets.urpf, null)
        directed_broadcast     = try(int.directed_broadcast, local.defaults.nxos.devices.configuration.interfaces.ethernets.directed_broadcast, null)
        directed_broadcast_acl = try(int.directed_broadcast_acl, local.defaults.nxos.devices.configuration.interfaces.ethernets.directed_broadcast_acl, null)
        ip_address             = try(int.ip_address, local.defaults.nxos.devices.configuration.interfaces.ethernets.ip_address, null)
        ip_secondary_addresses = try(int.ip_secondary_addresses, [])
        } if try(int.layer3, local.defaults.nxos.devices.configuration.interfaces.ethernets.layer3, false)
      ],
      # Loopbacks
      [for int in try(local.device_config[device.name].interfaces.loopbacks, []) : {
        device                 = device.name
        vrf                    = try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.loopbacks.vrf, "default")
        id                     = "lo${int.id}"
        drop_glean             = null
        forward                = null
        unnumbered             = null
        urpf                   = null
        directed_broadcast     = null
        directed_broadcast_acl = null
        ip_address             = try(int.ip_address, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ip_address, null)
        ip_secondary_addresses = try(int.ip_secondary_addresses, [])
      }],
      # SVIs
      [for int in try(local.device_config[device.name].interfaces.vlans, []) : {
        device                 = device.name
        vrf                    = try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.vlans.vrf, "default")
        id                     = "vlan${int.id}"
        drop_glean             = try(int.ip_drop_glean, local.defaults.nxos.devices.configuration.interfaces.vlans.ip_drop_glean, null) != null ? (try(int.ip_drop_glean, local.defaults.nxos.devices.configuration.interfaces.vlans.ip_drop_glean) ? "enabled" : "disabled") : null
        forward                = try(int.ip_forward, local.defaults.nxos.devices.configuration.interfaces.vlans.ip_forward, null) != null ? (try(int.ip_forward, local.defaults.nxos.devices.configuration.interfaces.vlans.ip_forward) ? "enabled" : "disabled") : null
        unnumbered             = null
        urpf                   = null
        directed_broadcast     = try(int.directed_broadcast, local.defaults.nxos.devices.configuration.interfaces.vlans.directed_broadcast, null)
        directed_broadcast_acl = try(int.directed_broadcast_acl, local.defaults.nxos.devices.configuration.interfaces.vlans.directed_broadcast_acl, null)
        ip_address             = try(int.ip_address, local.defaults.nxos.devices.configuration.interfaces.vlans.ip_address, null)
        ip_secondary_addresses = try(int.ip_secondary_addresses, [])
      }],
      # Port channels (layer3 only)
      [for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        device                 = device.name
        vrf                    = try(int.vrf, local.defaults.nxos.devices.configuration.interfaces.port_channels.vrf, "default")
        id                     = "po${int.id}"
        drop_glean             = null
        forward                = null
        unnumbered             = try(int.ip_unnumbered, local.defaults.nxos.devices.configuration.interfaces.port_channels.ip_unnumbered, null)
        urpf                   = try(int.urpf, local.defaults.nxos.devices.configuration.interfaces.port_channels.urpf, null)
        directed_broadcast     = try(int.directed_broadcast, local.defaults.nxos.devices.configuration.interfaces.port_channels.directed_broadcast, null)
        directed_broadcast_acl = try(int.directed_broadcast_acl, local.defaults.nxos.devices.configuration.interfaces.port_channels.directed_broadcast_acl, null)
        ip_address             = try(int.ip_address, local.defaults.nxos.devices.configuration.interfaces.port_channels.ip_address, null)
        ip_secondary_addresses = try(int.ip_secondary_addresses, [])
        } if try(int.layer3, local.defaults.nxos.devices.configuration.interfaces.port_channels.layer3, false)
      ],
    )
  ])
}

resource "nxos_ipv4" "ipv4" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].system.ip_routing, local.defaults.nxos.devices.configuration.system.ip_routing, null) != null ||
    try(local.device_config[device.name].system.ip_access_list_match_local_traffic, local.defaults.nxos.devices.configuration.system.ip_access_list_match_local_traffic, null) != null ||
    try(local.device_config[device.name].system.hardware_ecmp_hash_offset_concatenation, local.defaults.nxos.devices.configuration.system.hardware_ecmp_hash_offset_concatenation, null) != null ||
    try(local.device_config[device.name].system.hardware_ecmp_hash_offset_value, local.defaults.nxos.devices.configuration.system.hardware_ecmp_hash_offset_value, null) != null ||
    try(local.device_config[device.name].system.hardware_ecmp_hash_polynomial, local.defaults.nxos.devices.configuration.system.hardware_ecmp_hash_polynomial, null) != null ||
    try(local.device_config[device.name].system.logging_level_ip, local.defaults.nxos.devices.configuration.system.logging_level_ip, null) != null ||
    try(local.device_config[device.name].system.ip_redirect_syslog, local.defaults.nxos.devices.configuration.system.ip_redirect_syslog, null) != null ||
    try(local.device_config[device.name].system.ip_redirect_syslog_interval, local.defaults.nxos.devices.configuration.system.ip_redirect_syslog_interval, null) != null ||
    try(local.device_config[device.name].system.ip_source_route, local.defaults.nxos.devices.configuration.system.ip_source_route, null) != null ||
    length(try(local.device_config[device.name].vrfs, [])) > 0 ||
    length(try(local.device_config[device.name].routing.ip_static_routes, [])) > 0 ||
  length([for int in local.ip_interfaces : int if int.device == device.name]) > 0 }
  device = each.key

  instance_admin_state                    = try(local.device_config[each.key].system.ip_routing, local.defaults.nxos.devices.configuration.system.ip_routing, null) != null ? (try(local.device_config[each.key].system.ip_routing, local.defaults.nxos.devices.configuration.system.ip_routing) ? "enabled" : "disabled") : null
  access_list_match_local                 = try(local.device_config[each.key].system.ip_access_list_match_local_traffic, local.defaults.nxos.devices.configuration.system.ip_access_list_match_local_traffic, null) != null ? (try(local.device_config[each.key].system.ip_access_list_match_local_traffic, local.defaults.nxos.devices.configuration.system.ip_access_list_match_local_traffic) ? "enabled" : "disabled") : null
  hardware_ecmp_hash_offset_concatenation = try(local.device_config[each.key].system.hardware_ecmp_hash_offset_concatenation, local.defaults.nxos.devices.configuration.system.hardware_ecmp_hash_offset_concatenation, null) != null ? (try(local.device_config[each.key].system.hardware_ecmp_hash_offset_concatenation, local.defaults.nxos.devices.configuration.system.hardware_ecmp_hash_offset_concatenation) ? "enabled" : "disabled") : null
  hardware_ecmp_hash_offset_value         = try(local.device_config[each.key].system.hardware_ecmp_hash_offset_value, local.defaults.nxos.devices.configuration.system.hardware_ecmp_hash_offset_value, null)
  hardware_ecmp_hash_polynomial           = try(local.device_config[each.key].system.hardware_ecmp_hash_polynomial, local.defaults.nxos.devices.configuration.system.hardware_ecmp_hash_polynomial, null)
  logging_level                           = try(local.device_config[each.key].system.logging_level_ip, local.defaults.nxos.devices.configuration.system.logging_level_ip, null)
  redirect_syslog                         = try(local.device_config[each.key].system.ip_redirect_syslog, local.defaults.nxos.devices.configuration.system.ip_redirect_syslog, null) != null ? (try(local.device_config[each.key].system.ip_redirect_syslog, local.defaults.nxos.devices.configuration.system.ip_redirect_syslog) ? "enabled" : "disabled") : null
  redirect_syslog_interval                = try(local.device_config[each.key].system.ip_redirect_syslog_interval, local.defaults.nxos.devices.configuration.system.ip_redirect_syslog_interval, null)
  source_route                            = try(local.device_config[each.key].system.ip_source_route, local.defaults.nxos.devices.configuration.system.ip_source_route, null) != null ? (try(local.device_config[each.key].system.ip_source_route, local.defaults.nxos.devices.configuration.system.ip_source_route) ? "enabled" : "disabled") : null

  vrfs = merge(
    # "default" VRF
    {
      "default" = {
        auto_discard                 = null
        icmp_errors_source_interface = null

        static_routes = { for route in try(local.ip_static_routes_by_device_vrf["${each.key}/default"], []) : route.route.prefix => {
          control    = try(route.route.bfd, local.defaults.nxos.devices.configuration.routing.ip_static_routes.bfd, false) ? "bfd" : (try(route.route.pervasive, local.defaults.nxos.devices.configuration.routing.ip_static_routes.pervasive, false) ? "pervasive" : null)
          preference = try(route.route.preference, local.defaults.nxos.devices.configuration.routing.ip_static_routes.preference, null)
          tag        = try(route.route.tag, local.defaults.nxos.devices.configuration.routing.ip_static_routes.tag, null)

          next_hops = { for nh in try(route.route.next_hops, []) : "${try(nh.interface, local.defaults.nxos.devices.configuration.routing.ip_static_routes.next_hops.interface, "unspecified")};${try(nh.address, local.defaults.nxos.devices.configuration.routing.ip_static_routes.next_hops.address, "0.0.0.0")};${try(nh.vrf, local.defaults.nxos.devices.configuration.routing.ip_static_routes.next_hops.vrf, "default")}" => {
            object     = try(nh.track, local.defaults.nxos.devices.configuration.routing.ip_static_routes.next_hops.track, null)
            preference = try(nh.preference, local.defaults.nxos.devices.configuration.routing.ip_static_routes.next_hops.preference, null)
            tag        = try(nh.tag, local.defaults.nxos.devices.configuration.routing.ip_static_routes.next_hops.tag, null)
            name       = try(nh.name, local.defaults.nxos.devices.configuration.routing.ip_static_routes.next_hops.name, null)
          } }
        } }

        interfaces = { for int in local.ip_interfaces : int.id => {
          drop_glean             = int.drop_glean
          forward                = int.forward
          unnumbered             = int.unnumbered
          urpf                   = int.urpf
          directed_broadcast     = int.directed_broadcast != null ? (int.directed_broadcast ? "enabled" : "disabled") : null
          directed_broadcast_acl = int.directed_broadcast_acl

          addresses = merge(
            int.ip_address != null ? { (int.ip_address) = { type = "primary" } } : {},
            { for ip in int.ip_secondary_addresses : ip => { type = "secondary" } }
          )
        } if int.device == each.key && int.vrf == "default" }
      }
    },
    # VRFs from configuration.vrfs[]
    { for vrf in try(local.device_config[each.key].vrfs, []) : vrf.name => {
      auto_discard                 = try(vrf.auto_discard, local.defaults.nxos.devices.configuration.vrfs.auto_discard, null) != null ? (try(vrf.auto_discard, local.defaults.nxos.devices.configuration.vrfs.auto_discard) ? "enabled" : "disabled") : null
      icmp_errors_source_interface = try(vrf.icmp_errors_source_interface_type, local.defaults.nxos.devices.configuration.vrfs.icmp_errors_source_interface_type, null) != null ? "${local.intf_prefix_map[try(vrf.icmp_errors_source_interface_type, local.defaults.nxos.devices.configuration.vrfs.icmp_errors_source_interface_type)]}${try(vrf.icmp_errors_source_interface_id, local.defaults.nxos.devices.configuration.vrfs.icmp_errors_source_interface_id, "")}" : null

      static_routes = { for route in try(local.ip_static_routes_by_device_vrf["${each.key}/${vrf.name}"], []) : route.route.prefix => {
        control    = try(route.route.bfd, local.defaults.nxos.devices.configuration.routing.ip_static_routes.bfd, false) ? "bfd" : (try(route.route.pervasive, local.defaults.nxos.devices.configuration.routing.ip_static_routes.pervasive, false) ? "pervasive" : null)
        preference = try(route.route.preference, local.defaults.nxos.devices.configuration.routing.ip_static_routes.preference, null)
        tag        = try(route.route.tag, local.defaults.nxos.devices.configuration.routing.ip_static_routes.tag, null)

        next_hops = { for nh in try(route.route.next_hops, []) : "${try(nh.interface, local.defaults.nxos.devices.configuration.routing.ip_static_routes.next_hops.interface, "unspecified")};${try(nh.address, local.defaults.nxos.devices.configuration.routing.ip_static_routes.next_hops.address, "0.0.0.0")};${try(nh.vrf, local.defaults.nxos.devices.configuration.routing.ip_static_routes.next_hops.vrf, "default")}" => {
          object     = try(nh.track, local.defaults.nxos.devices.configuration.routing.ip_static_routes.next_hops.track, null)
          preference = try(nh.preference, local.defaults.nxos.devices.configuration.routing.ip_static_routes.next_hops.preference, null)
          tag        = try(nh.tag, local.defaults.nxos.devices.configuration.routing.ip_static_routes.next_hops.tag, null)
          name       = try(nh.name, local.defaults.nxos.devices.configuration.routing.ip_static_routes.next_hops.name, null)
        } }
      } }

      interfaces = { for int in local.ip_interfaces : int.id => {
        drop_glean             = int.drop_glean
        forward                = int.forward
        unnumbered             = int.unnumbered
        urpf                   = int.urpf
        directed_broadcast     = int.directed_broadcast != null ? (int.directed_broadcast ? "enabled" : "disabled") : null
        directed_broadcast_acl = int.directed_broadcast_acl

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
