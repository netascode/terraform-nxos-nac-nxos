locals {
  igmp_interfaces_raw = flatten([
    for device in local.devices : concat(
      [for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        device       = device.name
        vrf          = try(int.vrf, "default")
        interface_id = "eth${int.id}"
        igmp         = int.igmp
      } if try(int.igmp, null) != null],
      [for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        device       = device.name
        vrf          = try(int.vrf, "default")
        interface_id = "po${int.id}"
        igmp         = int.igmp
      } if try(int.igmp, null) != null],
      [for int in try(local.device_config[device.name].interfaces.loopbacks, []) : {
        device       = device.name
        vrf          = try(int.vrf, "default")
        interface_id = "lo${int.id}"
        igmp         = int.igmp
      } if try(int.igmp, null) != null],
      [for int in try(local.device_config[device.name].interfaces.vlans, []) : {
        device       = device.name
        vrf          = try(int.vrf, "default")
        interface_id = "vlan${int.id}"
        igmp         = int.igmp
      } if try(int.igmp, null) != null],
      # Subinterfaces (ethernets)
      flatten([for eth in try(local.device_config[device.name].interfaces.ethernets, []) :
        [for sub in try(eth.subinterfaces, []) : {
          device       = device.name
          vrf          = try(sub.vrf, "default")
          interface_id = "eth${eth.id}.${sub.id}"
          igmp         = sub.igmp
        } if try(sub.igmp, null) != null]
      ]),
      # Subinterfaces (port channels)
      flatten([for pc in try(local.device_config[device.name].interfaces.port_channels, []) :
        [for sub in try(pc.subinterfaces, []) : {
          device       = device.name
          vrf          = try(sub.vrf, "default")
          interface_id = "po${pc.id}.${sub.id}"
          igmp         = sub.igmp
        } if try(sub.igmp, null) != null]
      ]),
    )
  ])

  # Join type "1" holds `ip igmp join-group` entries, join type "0" holds `ip igmp static-group` and `ip igmp static-oif`
  # entries. Groups without a source are stored under version "2", groups with a source under version "3". The
  # `use_static_oif` flags reproduce what the CLI writes: set on the group (version "2") or source (version "3") of a
  # static OIF, and always set on version "3" groups.
  igmp_interfaces = [for int in local.igmp_interfaces_raw : merge(int, {
    groups = concat(
      [for g in try(int.igmp.join_groups, []) : { type = "1", group = g.group, source = try(g.source, null), static_oif = false }],
      [for g in try(int.igmp.static_groups, []) : { type = "0", group = g.group, source = try(g.source, null), static_oif = false }],
      [for g in try(int.igmp.static_oifs, []) : { type = "0", group = g.group, source = try(g.source, null), static_oif = true }],
    )
  })]

  igmp_interfaces_by_device_vrf = { for int in local.igmp_interfaces :
    "${int.device}/${int.vrf}" => int...
  }

  # SSM translations per device and VRF: `igmp.ssm_translates` for the default VRF, `vrfs[].igmp_ssm_translates` otherwise
  igmp_ssm_translates_by_device_vrf = { for device in local.devices : device.name => merge(
    { for vrf in try(local.device_config[device.name].vrfs, []) : vrf.name => vrf.igmp_ssm_translates if length(try(vrf.igmp_ssm_translates, [])) > 0 },
    length(try(local.device_config[device.name].igmp.ssm_translates, [])) > 0 ? { "default" = local.device_config[device.name].igmp.ssm_translates } : {},
  ) }

  igmp_vrfs_by_device = { for device in local.devices : device.name => distinct(concat(
    keys(local.igmp_ssm_translates_by_device_vrf[device.name]),
    [for int in local.igmp_interfaces : int.vrf if int.device == device.name],
  )) }
}

resource "nxos_igmp" "igmp" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].igmp, null) != null ||
  length(local.igmp_vrfs_by_device[device.name]) > 0 }
  device                  = each.key
  any_query_destination   = try(local.device_config[each.key].igmp.any_query_destination, null)
  bootup_delay            = try(local.device_config[each.key].igmp.bootup_delay, null)
  control                 = try(local.device_config[each.key].igmp.ha_stateful, null) == null ? null : (try(local.device_config[each.key].igmp.ha_stateful) ? "stateful-ha" : "")
  flush_routes            = try(local.device_config[each.key].igmp.flush_routes, null)
  heavy_template          = try(local.device_config[each.key].igmp.heavy_template, null)
  enforce_router_alert    = try(local.device_config[each.key].igmp.enforce_router_alert, null)
  spoof_check             = try(local.device_config[each.key].igmp.spoof_check, null)
  strict_querier_election = try(local.device_config[each.key].igmp.querier_elect_strict, null)
  syslog_threshold        = try(local.device_config[each.key].igmp.syslog_threshold, null)

  vrfs = length(local.igmp_vrfs_by_device[each.key]) > 0 ? { for vrf in local.igmp_vrfs_by_device[each.key] : vrf => {
    ssm_translations = length(try(local.igmp_ssm_translates_by_device_vrf[each.key][vrf], [])) > 0 ? { for ssm in local.igmp_ssm_translates_by_device_vrf[each.key][vrf] :
      "${strcontains(ssm.group, "/") ? ssm.group : "${ssm.group}/32"};${strcontains(ssm.source, "/") ? ssm.source : "${ssm.source}/32"}" => {}
    } : null

    interfaces = length(try(local.igmp_interfaces_by_device_vrf["${each.key}/${vrf}"], [])) > 0 ? { for int in local.igmp_interfaces_by_device_vrf["${each.key}/${vrf}"] : int.interface_id => {
      allow_v3_asm                    = try(int.igmp.allow_v3_asm, null)
      group_timeout                   = try(int.igmp.group_timeout, null)
      immediate_leave                 = try(int.igmp.immediate_leave, null)
      report_link_local_groups        = try(int.igmp.report_link_local_groups, null)
      suppress_v3_gsq                 = try(int.igmp.suppress_v3_gsq, null)
      version                         = try(int.igmp.version, null) != null ? "v${int.igmp.version}" : null
      last_member_query_count         = try(int.igmp.last_member_query_count, null)
      last_member_query_response_time = try(int.igmp.last_member_query_response_time, null)
      querier_timeout                 = try(int.igmp.querier_timeout, null)
      query_interval                  = try(int.igmp.query_interval, null)
      robustness_variable             = try(int.igmp.robustness_variable, null)
      query_max_response_time         = try(int.igmp.query_max_response_time, null)
      startup_query_count             = try(int.igmp.startup_query_count, null)
      startup_query_interval          = try(int.igmp.startup_query_interval, null)
      report_policy_route_map         = try(int.igmp.report_policy, int.igmp.access_group, null)
      report_policy_prefix_list       = try(int.igmp.report_policy_prefix_list, int.igmp.access_group_prefix_list, null)
      report_policy_access_group      = try(int.igmp.access_group, int.igmp.access_group_prefix_list, null) != null ? true : try(int.igmp.report_policy, int.igmp.report_policy_prefix_list, null) != null ? false : null
      state_limit_maximum             = try(int.igmp.state_limit, null)
      state_limit_reserved            = try(int.igmp.state_limit_reserved, null)
      state_limit_reserved_route_map  = try(int.igmp.state_limit_reserved_route_map, null)

      static_report_policies = anytrue([try(int.igmp.static_oif_route_map, null) != null, try(int.igmp.join_group_route_map, null) != null]) ? merge(
        try(int.igmp.static_oif_route_map, null) == null ? {} : { "0" = { route_map = int.igmp.static_oif_route_map } },
        try(int.igmp.join_group_route_map, null) == null ? {} : { "1" = { route_map = int.igmp.join_group_route_map } },
      ) : null

      join_types = length(int.groups) > 0 ? { for type in distinct([for g in int.groups : g.type]) : type => {
        versions = { for version in distinct([for g in int.groups : g.source == null ? "2" : "3" if g.type == type]) : version => {
          groups = { for group in distinct([for g in int.groups : g.group if g.type == type && (g.source == null ? "2" : "3") == version]) : group => {
            use_static_oif = version == "3" ? true : anytrue([for g in int.groups : g.static_oif if g.type == type && g.group == group && g.source == null])
            sources = version == "3" ? { for g in int.groups : g.source => {
              use_static_oif = g.static_oif
            } if g.type == type && g.group == group && g.source != null } : null
          } }
        } }
      } } : null
    } } : null
  } } : null

  depends_on = [
    nxos_cli.cli_pre_9,
    nxos_feature.feature,
    nxos_loopback_interface.loopback_interface,
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
    nxos_route_policy.route_policy,
    nxos_subinterface.subinterface,
    nxos_svi_interface.svi_interface,
    nxos_vrf.vrf,
  ]
}
