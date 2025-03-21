resource "nxos_bgp" "bgp" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.feature.bgp, local.defaults.nxos.devices.configuration.system.feature.bgp, false) }
  device      = each.key
  admin_state = "enabled"

  depends_on = [
    nxos_feature_bgp.bgp
  ]
}

resource "nxos_bgp_instance" "bgp_instance" {
  for_each                = { for device in local.devices : device.name => device if try(local.device_config[device.name].routing.bgp.asn, null) != null || try(local.defaults.nxos.configuration.routing.bgp.asn, null) != null }
  device                  = each.value.name
  admin_state             = "enabled"
  asn                     = try(local.device_config[each.value.name].routing.bgp.asn, local.defaults.nxos.configuration.routing.bgp.asn)
  enhanced_error_handling = try(local.device_config[each.value.name].routing.bgp.enhanced_error_handling, local.defaults.nxos.configuration.routing.bgp.enhanced_error_handling, false)

  depends_on = [
    nxos_bgp.bgp
  ]
}

locals {
  routing_bgp_vrfs = flatten([
    for device in local.devices : [
      for vrf in try(local.device_config[device.name].routing.bgp.vrfs, []) : {
        key                             = format("%s/%s", device.name, vrf.vrf)
        device                          = device.name
        vrf                             = vrf.vrf
        router_id                       = try(vrf.router_id, local.defaults.nxos.configuration.routing.bgp.vrfs.router_id, null)
        log_neighbor_changes            = try(vrf.log_neighbor_changes, local.defaults.nxos.configuration.routing.bgp.vrfs.log_neighbor_changes, false) ? "enabled" : "disabled"
        graceful_restart_stalepath_time = try(vrf.graceful_restart_stalepath_time, local.defaults.nxos.configuration.routing.bgp.vrfs.graceful_restart_stalepath_time, null)
        graceful_restart_restart_time   = try(vrf.graceful_restart_restart_time, local.defaults.nxos.configuration.routing.bgp.vrfs.graceful_restart_restart_time, null)
      }
    ]
  ])
}

resource "nxos_bgp_vrf" "bgp_vrf" {
  for_each  = { for v in local.routing_bgp_vrfs : v.key => v }
  device    = each.value.device
  asn       = nxos_bgp_instance.bgp_instance[each.value.device].asn
  name      = each.value.vrf
  router_id = each.value.router_id
}

resource "nxos_bgp_route_control" "bgp_route_control" {
  for_each             = { for v in local.routing_bgp_vrfs : v.key => v }
  device               = each.value.device
  asn                  = nxos_bgp_instance.bgp_instance[each.value.device].asn
  vrf                  = nxos_bgp_vrf.bgp_vrf[each.key].name
  log_neighbor_changes = each.value.log_neighbor_changes
}

resource "nxos_bgp_graceful_restart" "bgp_graceful_restart" {
  for_each         = { for v in local.routing_bgp_vrfs : v.key => v }
  device           = each.value.device
  asn              = nxos_bgp_instance.bgp_instance[each.value.device].asn
  vrf              = nxos_bgp_vrf.bgp_vrf[each.key].name
  restart_interval = each.value.graceful_restart_restart_time
  stale_interval   = each.value.graceful_restart_stalepath_time
}


locals {
  routing_bgp_address_family = flatten([
    for device in local.devices : [
      for vrf in try(local.device_config[device.name].routing.bgp.vrfs, []) : [
        for af in try(vrf.address_families, []) : {
          key                                    = format("%s/%s/%s", device.name, vrf.vrf, af.address_family)
          device                                 = device.name
          vrf                                    = vrf.vrf
          address_family                         = local.address_family_names_map[af.address_family]
          advertise_l2vpn_evpn                   = try(af.advertise_l2vpn_evpn, local.defaults.nxos.configuration.routing.bgp.vrfs.address_families.advertise_l2vpn_evpn, false) ? "enabled" : "disabled",
          advertise_only_active_routes           = try(af.advertise_only_active_routes, local.defaults.nxos.configuration.routing.bgp.vrfs.address_families.advertise_only_active_routes, false) ? "enabled" : "disabled",
          advertise_physical_ip_for_type5_routes = try(af.advertise_physical_ip_for_type5_routes, local.defaults.nxos.configuration.routing.bgp.vrfs.address_families.advertise_physical_ip_for_type5_routes, false) ? "enabled" : "disabled",
          critical_nexthop_timeout               = try(af.critical_nexthop_timeout, local.defaults.nxos.configuration.routing.bgp.vrfs.address_families.critical_nexthop_timeout, "crit")
          default_information_originate          = try(af.default_information_originate, local.defaults.nxos.configuration.routing.bgp.vrfs.address_families.default_information_originate, false) ? "enabled" : "disabled",
          max_ecmp_paths                         = try(af.max_ecmp_paths, local.defaults.nxos.configuration.routing.bgp.vrfs.address_families.max_ecmp_paths, 1)
          max_external_ecmp_paths                = try(af.max_external_ecmp_paths, local.defaults.nxos.configuration.routing.bgp.vrfs.address_families.max_external_ecmp_paths, 1)
          max_external_internal_ecmp_paths       = try(af.max_external_internal_ecmp_paths, local.defaults.nxos.configuration.routing.bgp.vrfs.address_families.max_external_internal_ecmp_paths, 1)
          max_local_ecmp_paths                   = try(af.max_local_ecmp_paths, local.defaults.nxos.configuration.routing.bgp.vrfs.address_families.max_local_ecmp_paths, 1)
          max_mixed_ecmp_paths                   = try(af.max_mixed_ecmp_paths, local.defaults.nxos.configuration.routing.bgp.vrfs.address_families.max_mixed_ecmp_paths, 1)
          next_hop_route_map_name                = try(af.next_hop_route_map_name, local.defaults.nxos.configuration.routing.bgp.vrfs.address_families.next_hop_route_map_name, "")
          non_critical_nexthop_timeout           = try(af.non_critical_nexthop_timeout, local.defaults.nxos.configuration.routing.bgp.vrfs.address_families.non_critical_nexthop_timeout, "noncrit")
          prefix_priority                        = try(af.prefix_priority, local.defaults.nxos.configuration.routing.bgp.vrfs.address_families.prefix_priority, "none")
          retain_rt_all                          = try(af.retain_rt_all, local.defaults.nxos.configuration.routing.bgp.vrfs.address_families.retain_rt_all, false) ? "enabled" : "disabled",
          table_map_route_map_name               = try(af.table_map_route_map_name, local.defaults.nxos.configuration.routing.bgp.vrfs.address_families.table_map_route_map_name, "")
          vni_ethernet_tag                       = try(af.vni_ethernet_tag, local.defaults.nxos.configuration.routing.bgp.vrfs.address_families.vni_ethernet_tag, false) ? "enabled" : "disabled",
          wait_igp_converged                     = try(af.wait_igp_converged, local.defaults.nxos.configuration.routing.bgp.vrfs.address_families.wait_igp_converged, false) ? "enabled" : "disabled",
        }
      ]
    ]
  ])
}

resource "nxos_bgp_address_family" "bgp_address_family" {
  for_each                               = { for v in local.routing_bgp_address_family : v.key => v }
  device                                 = each.value.device
  asn                                    = nxos_bgp_instance.bgp_instance[each.value.device].asn
  vrf                                    = each.value.vrf
  address_family                         = each.value.address_family
  advertise_l2vpn_evpn                   = each.value.advertise_l2vpn_evpn
  advertise_only_active_routes           = each.value.advertise_only_active_routes
  advertise_physical_ip_for_type5_routes = each.value.advertise_physical_ip_for_type5_routes
  critical_nexthop_timeout               = each.value.critical_nexthop_timeout
  default_information_originate          = each.value.default_information_originate
  max_ecmp_paths                         = each.value.max_ecmp_paths
  max_external_ecmp_paths                = each.value.max_external_ecmp_paths
  max_external_internal_ecmp_paths       = each.value.max_external_internal_ecmp_paths
  max_local_ecmp_paths                   = each.value.max_local_ecmp_paths
  max_mixed_ecmp_paths                   = each.value.max_mixed_ecmp_paths
  next_hop_route_map_name                = each.value.next_hop_route_map_name
  non_critical_nexthop_timeout           = each.value.non_critical_nexthop_timeout
  prefix_priority                        = each.value.prefix_priority
  retain_rt_all                          = each.value.retain_rt_all
  table_map_route_map_name               = each.value.table_map_route_map_name
  vni_ethernet_tag                       = each.value.vni_ethernet_tag
  wait_igp_converged                     = each.value.wait_igp_converged
  depends_on                             = [nxos_bgp_vrf.bgp_vrf]
}

locals {
  routing_bgp_advertised_prefix = flatten([
    for device in local.devices : [
      for vrf in try(local.device_config[device.name].routing.bgp.vrfs, []) : [
        for af in try(vrf.address_families, []) : [
          for prefix in try(af.networks, []) : [
            {
              key            = format("%s/%s/%s/%s", device.name, vrf.vrf, af.address_family, prefix.prefix)
              device         = device.name
              vrf            = vrf.vrf
              address_family = local.address_family_names_map[af.address_family]
              prefix         = prefix.prefix
              route_map      = try(prefix.route_map, null)
              evpn           = try(prefix.evpn, false) ? "enabled" : "disabled",
            }
          ]
        ]
      ]
    ]
  ])
}

resource "nxos_bgp_advertised_prefix" "bgp_advertised_prefix" {
  for_each       = { for v in local.routing_bgp_advertised_prefix : v.key => v }
  device         = each.value.device
  asn            = nxos_bgp_instance.bgp_instance[each.value.device].asn
  vrf            = each.value.vrf
  address_family = each.value.address_family
  prefix         = each.value.prefix
  route_map      = each.value.route_map
  evpn           = each.value.evpn
  depends_on     = [nxos_bgp_address_family.bgp_address_family]
}

locals {
  routing_bgp_route_redistribution = flatten([
    for device in local.devices : [
      for vrf in try(local.device_config[device.name].routing.bgp.vrfs, []) : [
        for af in try(vrf.address_families, []) : [
          for redistribution in try(af.redistributions, []) : [
            {
              key               = format("%s/%s/%s/%s", device.name, vrf.vrf, af.address_family, redistribution.protocol)
              device            = device.name
              vrf               = vrf.vrf
              address_family    = local.address_family_names_map[af.address_family]
              protocol          = redistribution.protocol
              protocol_instance = try(redistribution.protocol_instance, "none")
              route_map         = try(redistribution.route_map, null)
              scope             = try(redistribution.scope, "inter")
              srv6_prefix_type  = try(redistribution.srv6_prefix_type, "unspecified")
            }
          ]
        ]
      ]
    ]
  ])
}

resource "nxos_bgp_route_redistribution" "bgp_route_redistribution" {
  for_each          = { for v in local.routing_bgp_route_redistribution : v.key => v }
  device            = each.value.device
  asn               = nxos_bgp_instance.bgp_instance[each.value.device].asn
  vrf               = each.value.vrf
  address_family    = each.value.address_family
  protocol          = each.value.protocol
  protocol_instance = each.value.protocol_instance
  route_map         = each.value.route_map
  scope             = each.value.scope
  srv6_prefix_type  = each.value.srv6_prefix_type
  depends_on        = [nxos_bgp_address_family.bgp_address_family]
}

locals {
  routing_bgp_peer_templates = flatten([
    for device in local.devices : [
      for peer in try(local.device_config[device.name].routing.bgp.peer_templates, []) : {
        key              = format("%s/%s", device.name, peer.name)
        device           = device.name
        name             = peer.name
        asn              = try(peer.asn, local.defaults.nxos.configuration.routing.bgp.peer_templates.asn, null)
        description      = try(peer.description, local.defaults.nxos.configuration.routing.bgp.peer_templates.description, null)
        peer_type        = try(peer.peer_type, local.defaults.nxos.configuration.routing.bgp.peer_templates.peer_type, null)
        source_interface = try(peer.source_interface, local.defaults.nxos.configuration.routing.bgp.peer_templates.source_interface, null)
      }
    ]
  ])
}

resource "nxos_bgp_peer_template" "bgp_peer_template" {
  for_each         = { for v in local.routing_bgp_peer_templates : v.key => v }
  device           = each.value.device
  asn              = nxos_bgp_instance.bgp_instance[each.value.device].asn
  template_name    = each.value.name
  remote_asn       = each.value.asn
  description      = each.value.description
  peer_type        = each.value.peer_type
  source_interface = each.value.source_interface
}

locals {
  address_family_names_map = {
    ipv4_unicast = "ipv4-ucast"
    ipv6_unicast = "ipv6-ucast"
    l2vpn_evpn   = "l2vpn-evpn"
  }
  routing_bgp_peer_templates_address_families = flatten([
    for device in local.devices : [
      for peer in try(local.device_config[device.name].routing.bgp.peer_templates, []) : [
        for af in try(peer.address_families, []) : {
          key                     = format("%s/%s/%s", device.name, peer.name, local.address_family_names_map[af.address_family])
          device                  = device.name
          template_peer_key       = format("%s/%s", device.name, peer.name)
          address_family          = local.address_family_names_map[af.address_family]
          control                 = try(af.route_reflector_client, local.defaults.nxos.configuration.routing.bgp.peer_templates.address_families.route_reflector_client, false) ? "rr-client" : ""
          send_community_extended = try(af.send_community_extended, local.defaults.nxos.configuration.routing.bgp.peer_templates.address_families.send_community_extended, false) ? "enabled" : "disabled"
          send_community_standard = try(af.send_community_standard, local.defaults.nxos.configuration.routing.bgp.peer_templates.address_families.send_community_standard, false) ? "enabled" : "disabled"
        }
      ]
    ]
  ])
}

resource "nxos_bgp_peer_template_address_family" "bgp_peer_template_address_family" {
  for_each                = { for v in local.routing_bgp_peer_templates_address_families : v.key => v }
  device                  = each.value.device
  asn                     = nxos_bgp_instance.bgp_instance[each.value.device].asn
  template_name           = nxos_bgp_peer_template.bgp_peer_template[each.value.template_peer_key].template_name
  address_family          = each.value.address_family
  control                 = each.value.control
  send_community_extended = each.value.send_community_extended
  send_community_standard = each.value.send_community_standard
}

locals {
  routing_bgp_vrfs_neighbors = flatten([
    for device in local.devices : [
      for vrf in try(local.device_config[device.name].routing.bgp.vrfs, []) : [
        for nei in try(vrf.neighbors, []) : {
          key              = format("%s/%s/%s", device.name, vrf.vrf, nei.ip)
          device           = device.name
          vrf_key          = format("%s/%s", device.name, vrf.vrf)
          ip               = nei.ip
          asn              = try(nei.asn, local.defaults.nxos.configuration.routing.bgp.vrfs.neighbors.asn, null)
          peer_template    = try(nei.peer_template, local.defaults.nxos.configuration.routing.bgp.vrfs.neighbors.peer_template, null)
          description      = try(nei.description, local.defaults.nxos.configuration.routing.bgp.vrfs.neighbors.description, null)
          peer_type        = try(nei.peer_type, local.defaults.nxos.configuration.routing.bgp.vrfs.neighbors.peer_type, null)
          source_interface = try(nei.source_interface, local.defaults.nxos.configuration.routing.bgp.vrfs.neighbors.source_interface, null)
        }
      ]
    ]
  ])
}

resource "nxos_bgp_peer" "bgp_peer" {
  for_each         = { for v in local.routing_bgp_vrfs_neighbors : v.key => v }
  device           = each.value.device
  asn              = nxos_bgp_instance.bgp_instance[each.value.device].asn
  vrf              = nxos_bgp_vrf.bgp_vrf[each.value.vrf_key].name
  address          = each.value.ip
  remote_asn       = each.value.asn
  description      = each.value.description
  peer_template    = each.value.peer_template
  peer_type        = each.value.peer_type
  source_interface = each.value.source_interface
}

locals {
  routing_bgp_vrfs_neighbors_address_families = flatten([
    for device in local.devices : [
      for vrf in try(local.device_config[device.name].routing.bgp.vrfs, []) : [
        for nei in try(vrf.neighbors, []) : [
          for af in try(nei.address_families, []) : {
            key                     = format("%s/%s/%s/%s", device.name, vrf.vrf, nei.ip, local.address_family_names_map[af.address_family])
            device                  = device.name
            vrf                     = vrf.vrf
            neighbor_key            = format("%s/%s/%s", device.name, vrf.vrf, nei.ip)
            address_family          = local.address_family_names_map[af.address_family]
            send_community_standard = try(af.send_community_standard, local.defaults.nxos.configuration.routing.bgp.vrfs.neighbors.address_families.send_community_standard, false) ? "enabled" : "disabled"
            send_community_extended = try(af.send_community_extended, local.defaults.nxos.configuration.routing.bgp.vrfs.neighbors.address_families.send_community_extended, false) ? "enabled" : "disabled"
            route_reflector_client  = try(af.route_reflector_client, local.defaults.nxos.configuration.routing.bgp.vrfs.neighbors.address_families.route_reflector_client, false) ? "rr-client" : ""
          }
        ]
      ]
    ]
  ])
}

resource "nxos_bgp_peer_address_family" "bgpPeerAf" {
  for_each                = { for v in local.routing_bgp_vrfs_neighbors_address_families : v.key => v }
  device                  = each.value.device
  asn                     = nxos_bgp_instance.bgp_instance[each.value.device].asn
  vrf                     = each.value.vrf
  address                 = nxos_bgp_peer.bgp_peer[each.value.neighbor_key].address
  address_family          = each.value.address_family
  control                 = each.value.route_reflector_client
  send_community_extended = each.value.send_community_extended
  send_community_standard = each.value.send_community_standard
}

locals {
  routing_bgp_vrfs_neighbors_address_families_route_control = flatten([
    for device in local.devices : [
      for vrf in try(local.device_config[device.name].routing.bgp.vrfs, []) : [
        for nei in try(vrf.neighbors, []) : [
          for af in try(nei.address_families, []) : [
            for direction in ["in", "out"] : (
              try(af["route_map_${direction}"], null) != null ? [
                {
                  key            = format("%s/%s/%s/%s/%s", device.name, vrf.vrf, nei.ip, local.address_family_names_map[af.address_family], direction)
                  device         = device.name
                  vrf            = vrf.vrf
                  neighbor_key   = format("%s/%s/%s", device.name, vrf.vrf, nei.ip)
                  address_family = local.address_family_names_map[af.address_family]
                  route_map_name = af["route_map_${direction}"]
                  direction      = direction
                }
              ] : []
            )
          ]
        ]
      ]
    ]
  ])
}

resource "nxos_bgp_peer_address_family_route_control" "bgp_peer_address_family_route_control" {
  for_each       = { for v in local.routing_bgp_vrfs_neighbors_address_families_route_control : v.key => v }
  device         = each.value.device
  asn            = nxos_bgp_instance.bgp_instance[each.value.device].asn
  vrf            = each.value.vrf
  address        = nxos_bgp_peer.bgp_peer[each.value.neighbor_key].address
  address_family = each.value.address_family
  route_map_name = each.value.route_map_name
  direction      = each.value.direction
}
