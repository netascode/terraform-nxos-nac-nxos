locals {
  vrfs = flatten([
    for device in local.devices : [
      for vrf in try(local.device_config[device.name].vrfs, []) : {
        key                 = format("%s/%s", device.name, vrf.name)
        device              = device.name
        name                = vrf.name
        description         = try(vrf.description, local.defaults.nxos.devices.configuration.vrfs.description, null)
        vni                 = try(vrf.vni, local.defaults.nxos.devices.configuration.vrfs.vni, null)
        route_distinguisher = try(vrf.route_distinguisher, local.defaults.nxos.devices.configuration.vrfs.route_distinguisher, null)
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

  vrfs_address_families = flatten([
    for device in local.devices : [
      for vrf in try(local.device_config[device.name].vrfs, []) : [
        for af in try(vrf.address_families, []) : {
          key                                = format("%s/%s/%s", device.name, vrf.name, local.vrf_address_family_names_map[af.address_family])
          device                             = device.name
          vrf                                = vrf.name
          vrf_key                            = format("%s/%s", device.name, vrf.name)
          address_family                     = local.vrf_address_family_names_map[af.address_family]
          route_target_both_auto             = try(af.route_target_both_auto, false)
          route_target_both_auto_evpn        = try(af.route_target_both_auto_evpn, false)
          route_target_imports               = try(af.route_target_imports, [])
          route_target_exports               = try(af.route_target_exports, [])
          route_target_imports_evpn          = try(af.route_target_imports_evpn, [])
          route_target_exports_evpn          = try(af.route_target_exports_evpn, [])
          route_target_imports_list_raw      = try(af.route_target_both_auto, false) ? concat(["auto"], try(af.route_target_imports, [])) : try(af.route_target_imports, [])
          route_target_exports_list_raw      = try(af.route_target_both_auto, false) ? concat(["auto"], try(af.route_target_exports, [])) : try(af.route_target_exports, [])
          route_target_imports_list_evpn_raw = try(af.route_target_both_auto_evpn, false) ? concat(["auto"], try(af.route_target_imports_evpn, [])) : try(af.route_target_imports_evpn, [])
          route_target_exports_list_evpn_raw = try(af.route_target_both_auto_evpn, false) ? concat(["auto"], try(af.route_target_exports_evpn, [])) : try(af.route_target_exports_evpn, [])
        }
      ]
    ]
  ])

  vrfs_address_families_flat = [
    for af in local.vrfs_address_families : merge(af, {
      flat = [
        {
          "direction"         = "import"
          "address_family"    = af.address_family
          "address_family_rt" = af.address_family
          "rt_set"            = toset(af.route_target_imports_list_raw)
        },
        {
          "direction"         = "export"
          "address_family"    = af.address_family
          "address_family_rt" = af.address_family
          "rt_set"            = toset(af.route_target_exports_list_raw)
        },
        {
          "direction"         = "import"
          "address_family"    = af.address_family
          "address_family_rt" = "l2vpn-evpn"
          "rt_set"            = toset(af.route_target_imports_list_evpn_raw)
        },
        {
          "direction"         = "export"
          "address_family"    = af.address_family
          "address_family_rt" = "l2vpn-evpn"
          "rt_set"            = toset(af.route_target_exports_list_evpn_raw)
        }
      ]
    })
  ]

  vrfs_address_families_map = [
    for af in local.vrfs_address_families_flat : merge(af, {
      map = {
        for entry in af.flat : "${entry.address_family}_${entry.address_family_rt}_${entry.direction}" => entry if length(entry.rt_set) > 0
      }
    })
  ]

  vrfs_address_families_rts = flatten([
    for af in local.vrfs_address_families_flat : toset([
      for entry in af.flat : {
        key                = format("%s/%s/%s/%s", af.device, af.vrf, af.address_family, entry.address_family_rt)
        device             = af.device
        vrf                = af.vrf
        address_family     = af.address_family
        address_family_key = format("%s/%s/%s", af.device, af.vrf, af.address_family)
        rt                 = entry.address_family_rt
      } if length(entry.rt_set) > 0
    ])
  ])

  vrfs_address_families_rts_direction = flatten([
    for af in local.vrfs_address_families_flat : toset([
      for entry in af.flat : {
        key                = format("%s/%s/%s/%s/%s", af.device, af.vrf, af.address_family, entry.address_family_rt, entry.direction)
        device             = af.device
        vrf                = af.vrf
        address_family     = af.address_family
        address_family_key = format("%s/%s/%s", af.device, af.vrf, af.address_family)
        rt                 = entry.address_family_rt
        rt_key             = format("%s/%s/%s/%s", af.device, af.vrf, af.address_family, entry.address_family_rt)
        direction          = entry.direction
      } if length(entry.rt_set) > 0
    ])
  ])

  vrfs_address_families_map_rt_helper = [
    for af in local.vrfs_address_families_map : merge(af, {
      rt_helper = {
        for k, v in af.map : k => [
          for value in v.rt_set : {
            "format_auto" = value == "auto" ? true : false
            "format_ipv4" = can(regex("\\.", value)) ? true : false
            "format_as2"  = !can(regex("\\.", value)) && can(regex(":", value)) ? (tonumber(split(":", value)[0]) <= 65535 ? true : false) : false
            "format_as4"  = !can(regex("\\.", value)) && can(regex(":", value)) ? (tonumber(split(":", value)[0]) >= 65536 ? true : false) : false
            "value"       = value
          }
        ]
      }
    })
  ]

  vrfs_address_families_map_rt_dme_format_map = [
    for af in local.vrfs_address_families_map_rt_helper : merge(af, {
      rt_dme_format_map = {
        for k, v in af.rt_helper : k => [
          for entry in v :
          entry.format_auto ? "route-target:unknown:0:0" : (
            entry.format_ipv4 ? "route-target:ipv4-nn2:${entry.value}" : (
              entry.format_as2 ? "route-target:as2-nn2:${entry.value}" : (
                entry.format_as4 ? "route-target:as4-nn2:${entry.value}" : "unexpected_rt_format"
          )))
        ]
      }
    })
  ]

  vrfs_address_families_map_dme = [
    for af in local.vrfs_address_families_map_rt_dme_format_map : merge(af, {
      map_dme = {
        for key, value in af.map : key => merge(value, { "rt_dme_format" : af.rt_dme_format_map[key] })
      }
    })
  ]

  vrfs_address_families_flat_dme = [
    for af in local.vrfs_address_families_map_dme : merge(af, {
      flat_dme = {
        for entry in flatten([
          for key, value in af.map_dme : [
            for rt in value.rt_dme_format : {
              "address_family"    = value.address_family
              "address_family_rt" = value.address_family_rt
              "direction"         = value.direction
              "rt"                = rt
              "key"               = "${key}_${rt}"
            }
          ]
      ]) : entry.key => entry }
    })
  ]

  vrfs_address_families_flat_dme_rts = flatten([
    for af in local.vrfs_address_families_flat_dme : [
      for k, v in af.flat_dme : {
        key               = format("%s/%s/%s/%s/%s/%s", af.device, af.vrf, af.address_family, v.address_family_rt, v.direction, v.rt)
        direction_key     = format("%s/%s/%s/%s/%s", af.device, af.vrf, af.address_family, v.address_family_rt, v.direction)
        device            = af.device
        vrf               = af.vrf
        address_family    = v.address_family
        address_family_rt = v.address_family_rt
        direction         = v.direction
        rt                = v.rt
      }
    ]
  ])
}

resource "nxos_vrf" "vrf" {
  for_each    = { for v in local.vrfs : v.key => v if v.name != "default" }
  device      = each.value.device
  name        = each.value.name
  description = each.value.description
  encap       = each.value.vni != null ? "vxlan-${each.value.vni}" : "unknown"
}

resource "nxos_vrf_routing" "vrf_routing" {
  for_each            = { for v in local.vrfs_rd_dme_format : v.key => v if v.name != "default" }
  device              = each.value.device
  vrf                 = nxos_vrf.vrf[each.key].name
  route_distinguisher = each.value.rd_dme_format
}

resource "nxos_vrf_address_family" "vrf_address_family" {
  for_each       = { for v in local.vrfs_address_families : v.key => v if v.vrf != "default" }
  device         = each.value.device
  vrf            = nxos_vrf_routing.vrf_routing[each.value.vrf_key].vrf
  address_family = each.value.address_family
}

resource "nxos_vrf_route_target_address_family" "vrf_route_target_address_family" {
  for_each                    = { for v in local.vrfs_address_families_rts : v.key => v }
  device                      = each.value.device
  vrf                         = each.value.vrf
  address_family              = nxos_vrf_address_family.vrf_address_family[each.value.address_family_key].address_family
  route_target_address_family = each.value.rt
}

resource "nxos_vrf_route_target_direction" "vrf_route_target_direction" {
  for_each                    = { for v in local.vrfs_address_families_rts_direction : v.key => v }
  device                      = each.value.device
  vrf                         = each.value.vrf
  address_family              = each.value.address_family
  route_target_address_family = nxos_vrf_route_target_address_family.vrf_route_target_address_family[each.value.rt_key].route_target_address_family
  direction                   = each.value.direction
}

resource "nxos_vrf_route_target" "vrf_route_target" {
  for_each                    = { for v in local.vrfs_address_families_flat_dme_rts : v.key => v }
  device                      = each.value.device
  vrf                         = each.value.vrf
  address_family              = each.value.address_family
  route_target_address_family = each.value.address_family_rt
  direction                   = nxos_vrf_route_target_direction.vrf_route_target_direction[each.value.direction_key].direction
  route_target                = each.value.rt
}

resource "nxos_ipv4_vrf" "ipv4_vrf" {
  for_each = { for v in local.vrfs : v.key => v }
  device   = each.value.device
  name     = each.value.name
}

resource "nxos_ipv4_vrf" "ipv4_vrf_default" {
  for_each = { for device in local.devices : device.name => device }
  device   = each.value.name
  name     = "default"
}
