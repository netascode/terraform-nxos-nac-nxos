locals {
  urpf_map = {
    "rx"                 = "strict"
    "any"                = "loose"
    "any-allow-default"  = "loose-allow-default"
    "rx-allow-vni-hosts" = "strict-allow-vni-hosts"
  }

  ip_load_sharing_address_map = {
    "source"                                              = "source"
    "destination-port"                                    = "destPort"
    "source-destination"                                  = "srcDest"
    "source-destination-gre"                              = "srcDestGre"
    "source-destination-gre-outer"                        = "srcDest"
    "source-destination-gtpu"                             = "srcDestGTPU"
    "source-destination-ipv6-flowlabel"                   = "srcDestIPv6FlowLabel"
    "source-destination-ttl"                              = "srcDestTTL"
    "source-destination-udf"                              = "srcDestUDF"
    "source-destination-port"                             = "srcDestPort"
    "source-destination-port-symmetric"                   = "srcDestSymmetric"
    "source-destination-port-inner-all"                   = "srcDestInnerAll"
    "source-destination-port-inner-all-infra-mode"        = "srcDestInnerAllInfra"
    "source-destination-port-inner-greheader"             = "srcDestInnerGre"
    "source-destination-port-inner-greheader-symmetric"   = "srcDestInnerGreSymmetric"
    "source-destination-port-rocev2-opcode"               = "srcDestPortRocev2Opcode"
    "source-destination-port-rocev2-queuepair"            = "srcDestPortRocev2Queuepair"
    "source-destination-port-rocev2-psn"                  = "srcDestPortRocev2Psn"
    "source-destination-port-rocev2-opcode-queuepair"     = "srcDestPortRocev2OpcodeQueuepair"
    "source-destination-port-rocev2-opcode-psn"           = "srcDestPortRocev2OpcodePsn"
    "source-destination-port-rocev2-queuepair-psn"        = "srcDestPortRocev2QueuepairPsn"
    "source-destination-port-rocev2-opcode-queuepair-psn" = "srcDestPortRocev2OpcodeQueuepairPsn"
  }

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
        ip_tag                                 = try(int.ip.tag, null)
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
        ip_tag                                 = try(int.ip.tag, null)
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
        ip_tag                                 = try(int.ip.tag, null)
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
        ip_tag                                 = try(int.ip.tag, null)
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
          ip_tag                                 = try(sub.ip.tag, null)
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
          ip_tag                                 = try(sub.ip.tag, null)
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
        ip_tag                                 = try(int.ip.tag, null)
        ip_secondary_addresses                 = try(int.ip.secondary_addresses, [])
      } if try(int.ip, null) != null],
    )
  ])

  ip_interfaces_by_device_vrf = {
    for entry in local.ip_interfaces : "${entry.device}/${entry.vrf}" => entry...
  }
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
    try(local.device_config[device.name].system.ip_load_sharing, null) != null ||
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
  load_sharing_mode                       = try(local.ip_load_sharing_address_map[local.device_config[each.key].system.ip_load_sharing.address], null)
  load_sharing_gre_outer_hash             = try(local.device_config[each.key].system.ip_load_sharing.address, null) != null ? (try(local.device_config[each.key].system.ip_load_sharing.address) == "source-destination-gre-outer" ? "enabled" : "disabled") : null
  load_sharing_udf_offset                 = try(local.device_config[each.key].system.ip_load_sharing.udf_offset, null)
  load_sharing_udf_length                 = try(local.device_config[each.key].system.ip_load_sharing.udf_length, null)
  load_sharing_exclude_l3_protocol        = try(local.device_config[each.key].system.ip_load_sharing.exclude_l3_proto, null) != null ? (try(local.device_config[each.key].system.ip_load_sharing.exclude_l3_proto) ? "enabled" : "disabled") : null
  load_sharing_rotate                     = try(local.device_config[each.key].system.ip_load_sharing.rotate, null)
  load_sharing_concatenation              = try(local.device_config[each.key].system.ip_load_sharing.concatenation, null) != null ? (try(local.device_config[each.key].system.ip_load_sharing.concatenation) ? "enabled" : "disabled") : null
  load_sharing_universal_id               = try(local.device_config[each.key].system.ip_load_sharing.universal_id, null)
  load_sharing_keyshift                   = try(local.device_config[each.key].system.ip_load_sharing.hardware_lb_keyshift, null)
  load_sharing_second_hierarchy_keyshift  = try(local.device_config[each.key].system.ip_load_sharing.hardware_lb_2nd_hier_keyshift, null)

  vrfs = merge(
    # "default" VRF
    {
      "default" = {
        auto_discard                 = null
        icmp_errors_source_interface = null

        static_routes = length(try(local.ip_routes_by_device_vrf["${each.key}/default"], [])) > 0 ? { for route in try(local.ip_routes_by_device_vrf["${each.key}/default"], []) : route.route.prefix => {
          control    = try(route.route.bfd, false) ? "bfd" : null
          preference = try(route.route.preference, null)
          tag        = try(route.route.tag, null)

          next_hops = length(try(route.route.next_hops, [])) > 0 ? { for nh in try(route.route.next_hops, []) : "${try(nh.interface_type, null) != null ? "${local.intf_prefix_map[try(nh.interface_type)]}${try(nh.interface_id, "")}" : "unspecified"};${try(nh.address, "0.0.0.0")};${try(nh.vrf, "default")}" => {
            object     = try(nh.track, null)
            preference = try(nh.preference, null)
            tag        = try(nh.tag, null)
            name       = try(nh.name, null)
          } } : null
        } } : null

        interfaces = length(try(local.ip_interfaces_by_device_vrf["${each.key}/default"], [])) > 0 ? { for int in local.ip_interfaces_by_device_vrf["${each.key}/default"] : int.id => {
          drop_glean             = int.drop_glean
          forward                = int.forward
          unnumbered             = int.unnumbered
          urpf                   = try(local.urpf_map[int.ip_verify_unicast_source_reachable_via], int.ip_verify_unicast_source_reachable_via)
          directed_broadcast     = int.ip_directed_broadcast != null ? (int.ip_directed_broadcast ? "enabled" : "disabled") : null
          directed_broadcast_acl = int.ip_directed_broadcast_acl

          addresses = (int.ip_address != null || length(int.ip_secondary_addresses) > 0) ? merge(
            int.ip_address != null ? { (int.ip_address) = { type = "primary", tag = int.ip_tag } } : {},
            { for sec in int.ip_secondary_addresses : sec.address => { type = "secondary", tag = try(sec.tag, null) } }
          ) : null
        } } : null
      }
    },
    # VRFs from configuration.vrfs[]
    { for vrf in try(local.device_config[each.key].vrfs, []) : vrf.name => {
      auto_discard                 = try(vrf.auto_discard, null) != null ? (try(vrf.auto_discard) ? "enabled" : "disabled") : null
      icmp_errors_source_interface = try(vrf.icmp_errors_source_interface_type, null) != null ? "${local.intf_prefix_map[try(vrf.icmp_errors_source_interface_type)]}${try(vrf.icmp_errors_source_interface_id, "")}" : null

      static_routes = length(try(local.ip_routes_by_device_vrf["${each.key}/${vrf.name}"], [])) > 0 ? { for route in try(local.ip_routes_by_device_vrf["${each.key}/${vrf.name}"], []) : route.route.prefix => {
        control    = try(route.route.bfd, false) ? "bfd" : (try(route.route.pervasive, false) ? "pervasive" : null)
        preference = try(route.route.preference, null)
        tag        = try(route.route.tag, null)

        next_hops = length(try(route.route.next_hops, [])) > 0 ? { for nh in try(route.route.next_hops, []) : "${try(nh.interface_type, null) != null ? "${local.intf_prefix_map[try(nh.interface_type)]}${try(nh.interface_id, "")}" : "unspecified"};${try(nh.address, "0.0.0.0")};${try(nh.vrf, "default")}" => {
          object     = try(nh.track, null)
          preference = try(nh.preference, null)
          tag        = try(nh.tag, null)
          name       = try(nh.name, null)
        } } : null
      } } : null

      interfaces = length(try(local.ip_interfaces_by_device_vrf["${each.key}/${vrf.name}"], [])) > 0 ? { for int in local.ip_interfaces_by_device_vrf["${each.key}/${vrf.name}"] : int.id => {
        drop_glean             = int.drop_glean
        forward                = int.forward
        unnumbered             = int.unnumbered
        urpf                   = try(local.urpf_map[int.ip_verify_unicast_source_reachable_via], int.ip_verify_unicast_source_reachable_via)
        directed_broadcast     = int.ip_directed_broadcast != null ? (int.ip_directed_broadcast ? "enabled" : "disabled") : null
        directed_broadcast_acl = int.ip_directed_broadcast_acl

        addresses = (int.ip_address != null || length(int.ip_secondary_addresses) > 0) ? merge(
          int.ip_address != null ? { (int.ip_address) = { type = "primary", tag = int.ip_tag } } : {},
          { for sec in int.ip_secondary_addresses : sec.address => { type = "secondary", tag = try(sec.tag, null) } }
        ) : null
      } } : null
    } }
  )

  depends_on = [
    nxos_cli.cli_pre_9,
    nxos_feature.feature,
    nxos_loopback_interface.loopback_interface,
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
    nxos_subinterface.subinterface,
    nxos_svi_interface.svi_interface,
    nxos_vrf.vrf,
    nxos_track.track,
  ]
}
