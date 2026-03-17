locals {
  vrfs = flatten([
    for device in local.devices : [
      for vrf in try(local.device_config[device.name].vrfs, []) : {
        key                 = format("%s/%s", device.name, vrf.name)
        device              = device.name
        name                = vrf.name
        description         = try(vrf.description, local.defaults.nxos.devices.configuration.vrfs.description, null)
        vni                 = try(vrf.vni, local.defaults.nxos.devices.configuration.vrfs.vni, null)
        l3vni               = try(vrf.l3vni, local.defaults.nxos.devices.configuration.vrfs.l3vni, null)
        route_distinguisher = try(vrf.route_distinguisher, local.defaults.nxos.devices.configuration.vrfs.route_distinguisher, null)
        routing_encap       = try(vrf.routing_encap, local.defaults.nxos.devices.configuration.vrfs.routing_encap, null)
        controller_id       = try(vrf.controller_id, local.defaults.nxos.devices.configuration.vrfs.controller_id, null)
        oui                 = try(vrf.oui, local.defaults.nxos.devices.configuration.vrfs.oui, null)
        vpn_id              = try(vrf.vpn_id, local.defaults.nxos.devices.configuration.vrfs.vpn_id, null)
        address_families    = try(vrf.address_families, [])
      }
    ]
  ])

  vrfs_rd = [
    for vrf in local.vrfs : merge(vrf, {
      rd_none = vrf.route_distinguisher == null ? true : false
      rd_auto = vrf.route_distinguisher == "auto" ? true : false
      rd_ipv4 = can(regex("\\.", vrf.route_distinguisher)) ? true : false
      rd_as2  = !can(regex("\\.", vrf.route_distinguisher)) && can(regex(":", vrf.route_distinguisher)) ? (tonumber(split(":", vrf.route_distinguisher)[0]) <= 65535 ? true : false) : false
      rd_as4  = !can(regex("\\.", vrf.route_distinguisher)) && can(regex(":", vrf.route_distinguisher)) ? (tonumber(split(":", vrf.route_distinguisher)[0]) >= 65536 ? true : false) : false
    })
  ]

  vrfs_rd_dme_format = [
    for vrf in local.vrfs_rd : merge(vrf, {
      rd_dme_format = vrf.rd_none ? "unknown:unknown:0:0" : (
        vrf.rd_auto ? "rd:unknown:0:0" : (
          vrf.rd_ipv4 ? "rd:ipv4-nn2:${vrf.route_distinguisher}" : (
            vrf.rd_as2 ? "rd:as2-nn2:${vrf.route_distinguisher}" : (
              vrf.rd_as4 ? "rd:as4-nn2:${vrf.route_distinguisher}" : "unexpected_rd_format"
      ))))
    })
  ]

  vrf_address_family_names_map = {
    "ipv4_unicast" : "ipv4-ucast"
    "ipv6_unicast" : "ipv6-ucast"
  }

  # Convert a single human-readable RT value to DME format
  # Helper: classify and convert RT values per AF
  vrfs_address_families_rt_entries = flatten([
    for device in local.devices : [
      for vrf in try(local.device_config[device.name].vrfs, []) : [
        for af in try(vrf.address_families, []) : concat(
          # Same AF import RTs
          [for rt in(try(af.route_target_both_auto, false) ? concat(["auto"], try(af.route_target_imports, [])) : try(af.route_target_imports, [])) : {
            key            = format("%s/%s/%s/%s/%s/%s", device.name, vrf.name, local.vrf_address_family_names_map[af.address_family], local.vrf_address_family_names_map[af.address_family], "import", rt)
            device         = device.name
            vrf            = vrf.name
            address_family = local.vrf_address_family_names_map[af.address_family]
            rt_af          = local.vrf_address_family_names_map[af.address_family]
            direction      = "import"
            rt_raw         = rt
            rt_dme = rt == "auto" ? "route-target:unknown:0:0" : (
              can(regex("\\.", rt)) ? "route-target:ipv4-nn2:${rt}" : (
                can(regex(":", rt)) ? (tonumber(split(":", rt)[0]) <= 65535 ? "route-target:as2-nn2:${rt}" : "route-target:as4-nn2:${rt}") : "unexpected_rt_format"
            ))
          }],
          # Same AF export RTs
          [for rt in(try(af.route_target_both_auto, false) ? concat(["auto"], try(af.route_target_exports, [])) : try(af.route_target_exports, [])) : {
            key            = format("%s/%s/%s/%s/%s/%s", device.name, vrf.name, local.vrf_address_family_names_map[af.address_family], local.vrf_address_family_names_map[af.address_family], "export", rt)
            device         = device.name
            vrf            = vrf.name
            address_family = local.vrf_address_family_names_map[af.address_family]
            rt_af          = local.vrf_address_family_names_map[af.address_family]
            direction      = "export"
            rt_raw         = rt
            rt_dme = rt == "auto" ? "route-target:unknown:0:0" : (
              can(regex("\\.", rt)) ? "route-target:ipv4-nn2:${rt}" : (
                can(regex(":", rt)) ? (tonumber(split(":", rt)[0]) <= 65535 ? "route-target:as2-nn2:${rt}" : "route-target:as4-nn2:${rt}") : "unexpected_rt_format"
            ))
          }],
          # EVPN import RTs
          [for rt in(try(af.route_target_both_auto_evpn, false) ? concat(["auto"], try(af.route_target_imports_evpn, [])) : try(af.route_target_imports_evpn, [])) : {
            key            = format("%s/%s/%s/%s/%s/%s", device.name, vrf.name, local.vrf_address_family_names_map[af.address_family], "l2vpn-evpn", "import", rt)
            device         = device.name
            vrf            = vrf.name
            address_family = local.vrf_address_family_names_map[af.address_family]
            rt_af          = "l2vpn-evpn"
            direction      = "import"
            rt_raw         = rt
            rt_dme = rt == "auto" ? "route-target:unknown:0:0" : (
              can(regex("\\.", rt)) ? "route-target:ipv4-nn2:${rt}" : (
                can(regex(":", rt)) ? (tonumber(split(":", rt)[0]) <= 65535 ? "route-target:as2-nn2:${rt}" : "route-target:as4-nn2:${rt}") : "unexpected_rt_format"
            ))
          }],
          # EVPN export RTs
          [for rt in(try(af.route_target_both_auto_evpn, false) ? concat(["auto"], try(af.route_target_exports_evpn, [])) : try(af.route_target_exports_evpn, [])) : {
            key            = format("%s/%s/%s/%s/%s/%s", device.name, vrf.name, local.vrf_address_family_names_map[af.address_family], "l2vpn-evpn", "export", rt)
            device         = device.name
            vrf            = vrf.name
            address_family = local.vrf_address_family_names_map[af.address_family]
            rt_af          = "l2vpn-evpn"
            direction      = "export"
            rt_raw         = rt
            rt_dme = rt == "auto" ? "route-target:unknown:0:0" : (
              can(regex("\\.", rt)) ? "route-target:ipv4-nn2:${rt}" : (
                can(regex(":", rt)) ? (tonumber(split(":", rt)[0]) <= 65535 ? "route-target:as2-nn2:${rt}" : "route-target:as4-nn2:${rt}") : "unexpected_rt_format"
            ))
          }]
        )
      ]
    ]
  ])

  # Group RT entries by device/vrf/af for nested map construction
  # Key: "device/vrf/af" => list of {rt_af, direction, rt_dme}
  vrfs_rt_by_af = {
    for entry in local.vrfs_address_families_rt_entries :
    format("%s/%s/%s", entry.device, entry.vrf, entry.address_family) => entry...
  }
}

resource "nxos_vrf" "vrf" {
  for_each = { for device in local.devices : device.name => device
  if length(try(local.device_config[device.name].vrfs, [])) > 0 }
  device = each.key

  vrfs = { for vrf in [for v in local.vrfs_rd_dme_format : v if v.device == each.key && v.name != "default"] : vrf.name => {
    description         = vrf.description
    controller_id       = vrf.controller_id
    encap               = vrf.vni != null ? "vxlan-${vrf.vni}" : null
    l3vni               = vrf.l3vni
    oui                 = vrf.oui
    vpn_id              = vrf.vpn_id
    routing_encap       = vrf.routing_encap
    route_distinguisher = vrf.rd_dme_format

    address_families = { for af in vrf.address_families : local.vrf_address_family_names_map[af.address_family] => {
      route_target_address_families = {
        for rt_af, rt_af_entries in {
          for entry in try(local.vrfs_rt_by_af[format("%s/%s/%s", each.key, vrf.name, local.vrf_address_family_names_map[af.address_family])], []) :
          entry.rt_af => entry...
          } : rt_af => {
          route_target_directions = {
            for dir, dir_entries in {
              for entry in rt_af_entries : entry.direction => entry...
              } : dir => {
              route_targets = { for entry in dir_entries : entry.rt_dme => {} }
            }
          }
        }
      }
    } }
  } }

  depends_on = [
    nxos_feature.feature,
  ]
}
