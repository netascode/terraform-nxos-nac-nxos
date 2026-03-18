locals {
  evpn_vnis = flatten([
    for device in local.devices : [
      for vni in try(local.device_config[device.name].evpn.vnis, []) : {
        key                    = format("%s/%s", device.name, vni.vni)
        device                 = device.name
        vni                    = vni.vni
        rd                     = try(vni.rd, local.defaults.nxos.devices.configuration.evpn.vnis.rd, null)
        route_target_both_auto = try(vni.route_target_both_auto, local.defaults.nxos.devices.configuration.evpn.vnis.route_target_both_auto, false)
        route_target_imports   = try(vni.route_target_both_auto, local.defaults.nxos.devices.configuration.evpn.vnis.route_target_both_auto, false) ? concat(["auto"], try(vni.route_target_imports, local.defaults.nxos.devices.configuration.evpn.vnis.route_target_imports, [])) : try(vni.route_target_imports, local.defaults.nxos.devices.configuration.evpn.vnis.route_target_imports, [])
        route_target_exports   = try(vni.route_target_both_auto, local.defaults.nxos.devices.configuration.evpn.vnis.route_target_both_auto, false) ? concat(["auto"], try(vni.route_target_exports, local.defaults.nxos.devices.configuration.evpn.vnis.route_target_exports, [])) : try(vni.route_target_exports, local.defaults.nxos.devices.configuration.evpn.vnis.route_target_exports, [])
        table_map              = try(vni.table_map, local.defaults.nxos.devices.configuration.evpn.vnis.table_map, null)
        table_map_filter       = try(vni.table_map_filter, local.defaults.nxos.devices.configuration.evpn.vnis.table_map_filter, null)
      }
    ]
  ])

  evpn_vnis_rd = [
    for vni in local.evpn_vnis : merge(vni, {
      rd_none = vni.rd == null ? true : false
      rd_auto = vni.rd == "auto" ? true : false
      rd_ipv4 = can(regex("\\.", vni.rd)) ? true : false
      rd_as2  = !can(regex("\\.", vni.rd)) && can(regex(":", vni.rd)) ? (tonumber(split(":", vni.rd)[0]) <= 65535 ? true : false) : false
      rd_as4  = !can(regex("\\.", vni.rd)) && can(regex(":", vni.rd)) ? (tonumber(split(":", vni.rd)[0]) >= 65536 ? true : false) : false
    })
  ]

  evpn_vnis_rd_dme_format = [
    for vni in local.evpn_vnis_rd : merge(vni, {
      rd_dme_format = vni.rd_none ? "unknown:unknown:0:0" : (
        vni.rd_auto ? "rd:unknown:0:0" : (
          vni.rd_ipv4 ? "rd:ipv4-nn2:${vni.rd}" : (
            vni.rd_as2 ? "rd:as2-nn2:${vni.rd}" : (
              vni.rd_as4 ? "rd:as4-nn2:${vni.rd}" : "unexpected_rd_format"
      ))))
    })
  ]

  evpn_vnis_rt_helper = [
    for vni in local.evpn_vnis_rd_dme_format : merge(vni, {
      rt_imports_helper = [
        for value in vni.route_target_imports : {
          format_auto = value == "auto" ? true : false
          format_ipv4 = can(regex("\\.", value)) ? true : false
          format_as2  = !can(regex("\\.", value)) && can(regex(":", value)) ? (tonumber(split(":", value)[0]) <= 65535 ? true : false) : false
          format_as4  = !can(regex("\\.", value)) && can(regex(":", value)) ? (tonumber(split(":", value)[0]) >= 65536 ? true : false) : false
          value       = value
        }
      ]
      rt_exports_helper = [
        for value in vni.route_target_exports : {
          format_auto = value == "auto" ? true : false
          format_ipv4 = can(regex("\\.", value)) ? true : false
          format_as2  = !can(regex("\\.", value)) && can(regex(":", value)) ? (tonumber(split(":", value)[0]) <= 65535 ? true : false) : false
          format_as4  = !can(regex("\\.", value)) && can(regex(":", value)) ? (tonumber(split(":", value)[0]) >= 65536 ? true : false) : false
          value       = value
        }
      ]
    })
  ]

  evpn_vnis_rt_dme_format = [
    for vni in local.evpn_vnis_rt_helper : merge(vni, {
      rt_imports_dme = [
        for entry in vni.rt_imports_helper :
        entry.format_auto ? "route-target:unknown:0:0" : (
          entry.format_ipv4 ? "route-target:ipv4-nn2:${entry.value}" : (
            entry.format_as2 ? "route-target:as2-nn2:${entry.value}" : (
              entry.format_as4 ? "route-target:as4-nn2:${entry.value}" : "unexpected_rt_format"
        )))
      ]
      rt_exports_dme = [
        for entry in vni.rt_exports_helper :
        entry.format_auto ? "route-target:unknown:0:0" : (
          entry.format_ipv4 ? "route-target:ipv4-nn2:${entry.value}" : (
            entry.format_as2 ? "route-target:as2-nn2:${entry.value}" : (
              entry.format_as4 ? "route-target:as4-nn2:${entry.value}" : "unexpected_rt_format"
        )))
      ]
    })
  ]

  evpn_vnis_per_device = {
    for device in local.devices : device.name => [
      for vni in local.evpn_vnis_rt_dme_format : vni if vni.device == device.name
    ]
  }
}

resource "nxos_evpn" "evpn" {
  for_each = { for device in local.devices : device.name => device
  if try(local.device_config[device.name].evpn, null) != null }
  device      = each.key
  admin_state = "enabled"

  vnis = { for vni in try(local.evpn_vnis_per_device[each.key], []) : "vxlan-${vni.vni}" => {
    route_distinguisher = vni.rd_dme_format
    table_map           = vni.table_map
    table_map_filter    = vni.table_map_filter

    route_target_directions = merge(
      length(vni.rt_imports_dme) > 0 ? {
        "import" = {
          route_targets = { for rt in vni.rt_imports_dme : rt => {} }
        }
      } : {},
      length(vni.rt_exports_dme) > 0 ? {
        "export" = {
          route_targets = { for rt in vni.rt_exports_dme : rt => {} }
        }
      } : {}
    )
  } }

  depends_on = [
    nxos_bgp.bgp,
    nxos_bridge_domain.bridge_domain,
    nxos_feature.feature,
  ]
}
