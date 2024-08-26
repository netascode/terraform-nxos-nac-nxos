locals {
  vnis = flatten([
    for device in local.devices : [
      for vni in try(local.device_config[device.name].evpn.vnis, []) : {
        key                           = format("%s/%s", device.name, vni.vni)
        device                        = device.name
        vni                           = vni.vni
        route_distinguisher           = try(vni.route_distinguisher, local.defaults.nxos.devices.configuration.evpn.vnis.route_distinguisher, null)
        route_target_both_auto        = try(vni.route_target_both_auto, local.defaults.nxos.devices.configuration.evpn.vnis.route_target_both_auto, false)
        route_target_imports          = try(vni.route_target_imports, local.defaults.nxos.devices.configuration.evpn.vnis.route_target_imports, [])
        route_target_exports          = try(vni.route_target_exports, local.defaults.nxos.devices.configuration.evpn.vnis.route_target_exports, [])
        route_target_imports_list_raw = try(vni.route_target_both_auto, local.defaults.nxos.devices.configuration.evpn.vnis.route_target_both_auto, false) ? concat(["auto"], try(vni.route_target_imports, local.defaults.nxos.devices.configuration.evpn.vnis.route_target_imports, [])) : try(vni.route_target_imports, local.defaults.nxos.devices.configuration.evpn.vnis.route_target_imports, [])
        route_target_exports_list_raw = try(vni.route_target_both_auto, local.defaults.nxos.devices.configuration.evpn.vnis.route_target_both_auto, false) ? concat(["auto"], try(vni.route_target_exports, local.defaults.nxos.devices.configuration.evpn.vnis.route_target_exports, [])) : try(vni.route_target_exports, local.defaults.nxos.devices.configuration.evpn.vnis.route_target_exports, [])
      }
    ]
  ])

  vnis_rd = [
    for vni in local.vnis : merge(vni, {
      rd_none = vni.route_distinguisher == null ? true : false
      rd_auto = vni.route_distinguisher == "auto" ? true : false
      rd_ipv4 = can(regex("\\.", vni.route_distinguisher)) ? true : false
      rd_as2  = !can(regex("\\.", vni.route_distinguisher)) && can(regex(":", vni.route_distinguisher)) ? (tonumber(split(":", vni.route_distinguisher)[0]) <= 65535 ? true : false) : false
      rd_as4  = !can(regex("\\.", vni.route_distinguisher)) && can(regex(":", vni.route_distinguisher)) ? (tonumber(split(":", vni.route_distinguisher)[0]) >= 65536 ? true : false) : false
    })
  ]

  vnis_rd_dme_format = [
    for vni in local.vnis_rd : merge(vni, {
      rd_dme_format = vni.rd_none ? "unknown:unknown:0:0" : (
        vni.rd_auto ? "rd:unknown:0:0" : (
          vni.rd_ipv4 ? "rd:ipv4-nn2:${vni.route_distinguisher}" : (
            vni.rd_as2 ? "rd:as2-nn2:${vni.route_distinguisher}" : (
              vni.rd_as4 ? "rd:as4-nn2:${vni.route_distinguisher}" : "unexpected_rd_format"
      ))))
    })
  ]

  vnis_flat = [
    for vni in local.vnis : merge(vni, {
      flat = [
        {
          "direction" = "import"
          "vni"       = vni.vni
          "rt_set"    = toset(vni.route_target_imports_list_raw)
        },
        {
          "direction" = "export"
          "vni"       = vni.vni
          "rt_set"    = toset(vni.route_target_exports_list_raw)
        }
      ]
    })
  ]

  vnis_map = [
    for vni in local.vnis_flat : merge(vni, {
      map = {
        for entry in vni.flat : "${entry.vni}_${entry.direction}" => entry if length(entry.rt_set) > 0
      }
    })
  ]

  vnis_map_direction = flatten([
    for vni in local.vnis_flat : toset([
      for entry in vni.flat : {
        key       = format("%s/%s/%s", vni.device, vni.vni, entry.direction)
        device    = vni.device
        vni       = vni.vni
        vni_key   = format("%s/%s", vni.device, vni.vni)
        direction = entry.direction
      } if length(entry.rt_set) > 0
    ])
  ])

  vnis_map_rt_helper = [
    for vni in local.vnis_map : merge(vni, {
      rt_helper = {
        for k, v in vni.map : k => [
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

  vnis_map_rt_dme_format_map = [
    for vni in local.vnis_map_rt_helper : merge(vni, {
      rt_dme_format_map = {
        for k, v in vni.rt_helper : k => [
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

  vnis_map_dme = [
    for vni in local.vnis_map_rt_dme_format_map : merge(vni, {
      map_dme = {
        for key, value in vni.map : key => merge(value, { "rt_dme_format" : vni.rt_dme_format_map[key] })
      }
    })
  ]

  vnis_flat_dme = [
    for vni in local.vnis_map_dme : merge(vni, {
      flat_dme = {
        for entry in flatten([
          for key, value in vni.map_dme : [
            for rt in value.rt_dme_format : {
              "vni"       = value.vni
              "direction" = value.direction
              "rt"        = rt
              "key"       = "${key}_${rt}"
            }
          ]
      ]) : entry.key => entry }
    })
  ]

  vnis_flat_dme_rts = flatten([
    for vni in local.vnis_flat_dme : [
      for k, v in vni.flat_dme : {
        key           = format("%s/%s/%s/%s", vni.device, vni.vni, v.direction, v.rt)
        direction_key = format("%s/%s/%s", vni.device, vni.vni, v.direction)
        vni_key       = format("%s/%s", vni.device, vni.vni)
        device        = vni.device
        direction     = v.direction
        rt            = v.rt
      }
    ]
  ])
}

resource "nxos_evpn" "evpn" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].evpn, null) != null }
  device      = each.value.name
  admin_state = "enabled"

  depends_on = [
    nxos_feature_evpn.evpn
  ]
}

resource "nxos_evpn_vni" "evpn_vni" {
  for_each            = { for v in local.vnis_rd_dme_format : v.key => v }
  device              = each.value.device
  encap               = "vxlan-${each.value.vni}"
  route_distinguisher = each.value.rd_dme_format

  depends_on = [
    nxos_evpn.evpn
  ]
}

resource "nxos_evpn_vni_route_target_direction" "evpn_vni_route_target_direction" {
  for_each  = { for v in local.vnis_map_direction : v.key => v }
  device    = each.value.device
  encap     = nxos_evpn_vni.evpn_vni[each.value.vni_key].encap
  direction = each.value.direction
}

resource "nxos_evpn_vni_route_target" "evpn_vni_route_target" {
  for_each     = { for v in local.vnis_flat_dme_rts : v.key => v }
  device       = each.value.device
  encap        = nxos_evpn_vni.evpn_vni[each.value.vni_key].encap
  direction    = nxos_evpn_vni_route_target_direction.evpn_vni_route_target_direction[each.value.direction_key].direction
  route_target = each.value.rt
}

