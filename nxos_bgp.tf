resource "nxos_bgp" "bgp" {
  for_each    = { for device in local.devices : device.name => device if try(contains(local.device_config[device.name].system.features, "bgp"), contains(local.defaults.nxos.configuration.system.features, "bgp"), false) }
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
            key                     = format("%s/%s/%s/%s", device.name, vrf.vrf, nei.ip, af.address_family)
            device                  = device.name
            vrf                     = vrf.vrf
            neighbor_key            = format("%s/%s/%s", device.name, vrf.vrf, nei.ip)
            address_family          = af.address_family
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
