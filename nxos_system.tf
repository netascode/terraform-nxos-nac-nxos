locals {
  log_event_map = {
    "link-status-default"  = "linkStatusDefault"
    "link-status-enable"   = "linkStatusEnable"
    "none"                 = "none"
    "trunk-status-default" = "trunkStatusDefault"
    "trunk-status-enable"  = "trunkStatusEnable"
  }
  layer_map = {
    "layer2" = "Layer2"
    "layer3" = "Layer3"
  }
  smart_licensing_transport_map = {
    "callhome" = "transportCallhome"
    "cslu"     = "transportCslu"
    "off"      = "transportOff"
    "smart"    = "transportSmart"
  }
  cdp_format_device_id_map = {
    "none"          = "none"
    "mac"           = "mac"
    "serial-number" = "serialNum"
    "system-name"   = "sysName"
  }
  platform_pc_lb_algo_map = {
    "dlb"             = "PC_LB_ALGO_DLB"
    "rtag7"           = "PC_LB_ALGO_RTAG7"
    "rtag7-murmur"    = "PC_LB_ALGO_RTAG7_MURMUR"
    "rtag7-local-crc" = "PC_LB_ALGO_RTAG7_LOCAL_CRC"
    "dynamic-pin"     = "PC_LB_ALGO_DYNAMIC_PIN"
  }
  platform_switching_mode_map = {
    "store-forward" = "STORE_FORWARD"
    "cut-through"   = "CUT_THROUGH"
  }

  nd_interfaces = flatten([
    for device in local.devices : concat(
      [for int in try(local.device_config[device.name].interfaces.vlans, []) : {
        device       = device.name
        vrf          = try(int.vrf, "default")
        interface_id = "vlan${int.id}"
        nd           = try(int.nd, {})
      } if try(int.nd, null) != null],
      [for int in try(local.device_config[device.name].interfaces.loopbacks, []) : {
        device       = device.name
        vrf          = try(int.vrf, "default")
        interface_id = "lo${int.id}"
        nd           = try(int.nd, {})
      } if try(int.nd, null) != null],
      [for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        device       = device.name
        vrf          = try(int.vrf, "default")
        interface_id = "eth${int.id}"
        nd           = try(int.nd, {})
      } if try(int.nd, null) != null],
      [for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        device       = device.name
        vrf          = try(int.vrf, "default")
        interface_id = "po${int.id}"
        nd           = try(int.nd, {})
      } if try(int.nd, null) != null],
    )
  ])

  cdp_interfaces = flatten([
    for device in local.devices : concat(
      [for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        device       = device.name
        interface_id = "eth${int.id}"
        cdp          = try(int.cdp, null)
      } if try(int.cdp, null) != null],
      [for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        device       = device.name
        interface_id = "po${int.id}"
        cdp          = try(int.cdp, null)
      } if try(int.cdp, null) != null],
      [for int in try(local.device_config[device.name].interfaces.management, []) : {
        device       = device.name
        interface_id = int.id
        cdp          = try(int.cdp, null)
      } if try(int.cdp, null) != null],
    )
  ])

  cdp_interfaces_by_device = { for entry in local.cdp_interfaces : entry.device => entry... }

  lldp_interfaces = flatten([
    for device in local.devices : concat(
      [for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        device                             = device.name
        interface_id                       = "eth${int.id}"
        lldp_receive                       = try(int.lldp_receive, null)
        lldp_transmit                      = try(int.lldp_transmit, null)
        lldp_tlv_set_management_address_v4 = try(int.lldp_tlv_set_management_address_v4, null)
        lldp_tlv_set_management_address_v6 = try(int.lldp_tlv_set_management_address_v6, null)
        lldp_tlv_set_vlan                  = try(int.lldp_tlv_set_vlan, null)
        lldp_dcbx_version                  = try(int.lldp_dcbx_version, null)
        } if try(int.lldp_receive, null) != null ||
        try(int.lldp_transmit, null) != null ||
        try(int.lldp_tlv_set_management_address_v4, null) != null ||
        try(int.lldp_tlv_set_management_address_v6, null) != null ||
        try(int.lldp_tlv_set_vlan, null) != null ||
      try(int.lldp_dcbx_version, null) != null],
      [for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        device                             = device.name
        interface_id                       = "po${int.id}"
        lldp_receive                       = try(int.lldp_receive, null)
        lldp_transmit                      = try(int.lldp_transmit, null)
        lldp_tlv_set_management_address_v4 = try(int.lldp_tlv_set_management_address_v4, null)
        lldp_tlv_set_management_address_v6 = try(int.lldp_tlv_set_management_address_v6, null)
        lldp_tlv_set_vlan                  = try(int.lldp_tlv_set_vlan, null)
        lldp_dcbx_version                  = try(int.lldp_dcbx_version, null)
        } if try(int.lldp_receive, null) != null ||
        try(int.lldp_transmit, null) != null ||
        try(int.lldp_tlv_set_management_address_v4, null) != null ||
        try(int.lldp_tlv_set_management_address_v6, null) != null ||
        try(int.lldp_tlv_set_vlan, null) != null ||
      try(int.lldp_dcbx_version, null) != null],
      [for int in try(local.device_config[device.name].interfaces.management, []) : {
        device                             = device.name
        interface_id                       = int.id
        lldp_receive                       = try(int.lldp_receive, null)
        lldp_transmit                      = try(int.lldp_transmit, null)
        lldp_tlv_set_management_address_v4 = try(int.lldp_tlv_set_management_address_v4, null)
        lldp_tlv_set_management_address_v6 = try(int.lldp_tlv_set_management_address_v6, null)
        lldp_tlv_set_vlan                  = try(int.lldp_tlv_set_vlan, null)
        lldp_dcbx_version                  = try(int.lldp_dcbx_version, null)
        } if try(int.lldp_receive, null) != null ||
        try(int.lldp_transmit, null) != null ||
        try(int.lldp_tlv_set_management_address_v4, null) != null ||
        try(int.lldp_tlv_set_management_address_v6, null) != null ||
        try(int.lldp_tlv_set_vlan, null) != null ||
      try(int.lldp_dcbx_version, null) != null],
    )
  ])

  lldp_interfaces_by_device = { for entry in local.lldp_interfaces : entry.device => entry... }

  udld_interfaces = flatten([
    for device in local.devices : [
      for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        device          = device.name
        interface_id    = "eth${int.id}"
        udld            = try(int.udld, null)
        udld_aggressive = try(int.udld_aggressive, null)
      } if try(int.udld, null) != null ||
      try(int.udld_aggressive, null) != null
    ]
  ])

  udld_interfaces_by_device = { for entry in local.udld_interfaces : entry.device => entry... }

  nd_interfaces_by_device = { for entry in local.nd_interfaces : entry.device => entry... }

  nd_vrfs_by_device = { for device_name, entries in local.nd_interfaces_by_device : device_name => {
    for vrf in distinct([for e in entries : e.vrf]) : vrf => {
      interfaces = { for e in entries : e.interface_id => e.nd if e.vrf == vrf }
    }
  } }

  nd_control_values = {
    "redirects"       = "redirects"
    "managed_cfg"     = "managed-cfg"
    "other_cfg"       = "other-cfg"
    "suppress_ra"     = "suppress-ra"
    "suppress_ra_mtu" = "suppress-ra-mtu"
  }
}

resource "nxos_system" "system" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].system.hostname, null) != null ||
    try(local.device_config[device.name].system.mtu, null) != null ||
    try(local.device_config[device.name].system.ethernet, null) != null ||
    try(local.device_config[device.name].system.boot, null) != null ||
    try(local.device_config[device.name].system.cfs_distribute, null) != null ||
    try(local.device_config[device.name].system.cfs_eth_distribute, null) != null ||
    try(local.device_config[device.name].system.cfs_ipv4_distribute, null) != null ||
    try(local.device_config[device.name].system.cfs_ipv4_mcast_address, null) != null ||
    try(local.device_config[device.name].system.cfs_ipv6_distribute, null) != null ||
    try(local.device_config[device.name].system.cfs_ipv6_mcast_address, null) != null ||
    length(try(local.device_config[device.name].system.cli_aliases, [])) > 0 ||
    try(local.device_config[device.name].system.copp_profile, null) != null ||
    try(local.device_config[device.name].system.copp_rate_limit, null) != null ||
    try(local.device_config[device.name].system.clock, null) != null ||
    try(local.device_config[device.name].system.icam_monitor_interval, null) != null ||
    try(local.device_config[device.name].system.icam_monitor_intervals, null) != null ||
    try(local.device_config[device.name].system.icam_monitor_scale, null) != null ||
    try(local.device_config[device.name].system.platform, null) != null ||
    try(local.device_config[device.name].system.smart_licensing_transport, null) != null ||
    try(local.device_config[device.name].system.smart_licensing_url_cslu, null) != null ||
    try(local.device_config[device.name].system.terminal_console_exec_timeout, null) != null ||
    try(local.device_config[device.name].system.line_vty_exec_timeout, null) != null ||
    try(local.device_config[device.name].system.line_vty_session_limit, null) != null ||
    length(try(local.device_config[device.name].system.vdcs, [])) > 0 ||
    try(local.device_config[device.name].arp, null) != null ||
    try(local.device_config[device.name].nd, null) != null ||
    try(local.device_config[device.name].cdp, null) != null ||
    try(local.device_config[device.name].dns, null) != null ||
    try(local.device_config[device.name].lldp, null) != null ||
    try(local.device_config[device.name].udld, null) != null ||
    try(local.device_config[device.name].vpc.ip_arp_synchronize, null) != null ||
    try(local.device_config[device.name].vpc.ipv6_nd_synchronize, null) != null ||
    try(local.device_config[device.name].system.nxapi, null) != null ||
    length(try(local.nd_interfaces_by_device[device.name], [])) > 0 ||
    length(try(local.cdp_interfaces_by_device[device.name], [])) > 0 ||
    length(try(local.lldp_interfaces_by_device[device.name], [])) > 0 ||
    length(try(local.udld_interfaces_by_device[device.name], [])) > 0 ||
  length(try(local.device_config[device.name].interfaces.management, [])) > 0 }
  device = each.key

  # topSystem attributes
  name = try(local.device_config[each.key].system.hostname, null)

  # ethpmInst attributes (ethernet)
  ethernet_mtu                                  = try(local.device_config[each.key].system.mtu, null)
  ethernet_default_admin_state                  = try(local.device_config[each.key].system.ethernet.default_switchport_shutdown, null) != null ? (try(local.device_config[each.key].system.ethernet.default_switchport_shutdown) ? "down" : "up") : null
  ethernet_admin_link_down_syslog_level         = try(local.device_config[each.key].system.ethernet.admin_link_down_syslog_level, null)
  ethernet_admin_link_up_syslog_level           = try(local.device_config[each.key].system.ethernet.admin_link_up_syslog_level, null)
  ethernet_allow_unsupported_sfp                = try(local.device_config[each.key].system.ethernet.service_unsupported_transceiver, null)
  ethernet_interface_syslog_info                = try(local.device_config[each.key].system.ethernet.interface_syslog_info, null)
  ethernet_log_event                            = try(local.device_config[each.key].system.ethernet.logging_event_port, null) != null ? try(local.log_event_map[try(local.device_config[each.key].system.ethernet.logging_event_port)], null) : null
  ethernet_default_layer                        = try(local.layer_map[try(local.device_config[each.key].system.ethernet.default_switchport)], null)
  ethernet_system_interface_admin_state         = try(local.device_config[each.key].system.ethernet.default_interface_shutdown, null)
  ethernet_system_link_failure_laser_on         = try(local.device_config[each.key].system.ethernet.link_failure_laser_on, null)
  ethernet_system_storm_control_multi_threshold = try(local.device_config[each.key].system.ethernet.storm_control_multicast, null)
  ethernet_vlan_tag_native                      = try(local.device_config[each.key].system.ethernet.dot1q_tag_native, null)

  # arpEntity / arpInst attributes
  arp_admin_state                         = "enabled"
  arp_instance_admin_state                = "enabled"
  arp_allow_static_arp_outside_subnet     = try(local.device_config[each.key].arp.allow_static_arp_outside_subnet, null) != null ? (try(local.device_config[each.key].arp.allow_static_arp_outside_subnet) ? "enabled" : "disabled") : null
  arp_unnumbered_svi_software_replication = try(local.device_config[each.key].arp.unnumbered_svi_software_replication, null) != null ? (try(local.device_config[each.key].arp.unnumbered_svi_software_replication) ? "enabled" : "disabled") : null
  arp_cache_limit                         = try(local.device_config[each.key].arp.cache_limit, null)
  arp_cache_syslog_rate                   = try(local.device_config[each.key].arp.cache_syslog_rate, null)
  arp_evpn_timeout                        = try(local.device_config[each.key].arp.evpn_timeout, null)
  arp_interface_cache_limit               = try(local.device_config[each.key].arp.cache_interface_limit, null)
  arp_ip_adjacency_route_distance         = try(local.device_config[each.key].arp.adjacency_route_distance, null)
  arp_ip_arp_cos                          = try(local.device_config[each.key].arp.cos, null)
  arp_off_list_timeout                    = try(local.device_config[each.key].arp.off_list_timeout, null)
  arp_rarp_fabric_forwarding              = try(local.device_config[each.key].arp.rarp_fabric_forwarding, null) != null ? (try(local.device_config[each.key].arp.rarp_fabric_forwarding) ? "enabled" : "disabled") : null
  arp_rarp_fabric_forwarding_rate         = try(local.device_config[each.key].arp.rarp_fabric_forwarding_rate, null)
  arp_resolve_outside_subnet              = try(local.device_config[each.key].arp.resolve_outside_subnet, null) != null ? (try(local.device_config[each.key].arp.resolve_outside_subnet) ? "enabled" : "disabled") : null
  arp_suppression_timeout                 = try(local.device_config[each.key].arp.suppression_timeout, null)
  arp_timeout                             = try(local.device_config[each.key].arp.timeout, null)

  # arpVpcDom nested map
  arp_vpc_domains = try(local.device_config[each.key].vpc.ip_arp_synchronize, null) != null ? { tostring(try(local.device_config[each.key].vpc.domain_id)) = {
    arp_sync = try(local.device_config[each.key].vpc.ip_arp_synchronize) ? "enabled" : "disabled"
  } } : {}

  # ndEntity / ndInst attributes
  nd_admin_state                         = "enabled"
  nd_instance_admin_state                = "enabled"
  nd_accept_solicit_neighbor_entry       = try(local.device_config[each.key].nd.accept_solicit_neighbor_entry, null)
  nd_aging_interval                      = try(local.device_config[each.key].nd.aging_interval, null)
  nd_cache_limit                         = try(local.device_config[each.key].nd.cache_limit, null)
  nd_cache_syslog_rate                   = try(local.device_config[each.key].nd.cache_syslog_rate, null)
  nd_ipv6_adjacency_route_distance       = try(local.device_config[each.key].nd.adjacency_route_distance, null)
  nd_off_list_timeout                    = try(local.device_config[each.key].nd.off_list_timeout, null)
  nd_probe_interval_for_solicit_neighbor = try(local.device_config[each.key].nd.probe_interval_for_solicit_neighbor, null)
  nd_solicit_neighbor_advertisement      = try(local.device_config[each.key].nd.solicit_neighbor_advertisement, null) != null ? (try(local.device_config[each.key].nd.solicit_neighbor_advertisement) ? "enabled" : "disabled") : null

  # ndVpcDom nested map
  nd_vpc_domains = try(local.device_config[each.key].vpc.ipv6_nd_synchronize, null) != null ? { tostring(try(local.device_config[each.key].vpc.domain_id)) = {
    nd_sync = try(local.device_config[each.key].vpc.ipv6_nd_synchronize) ? "enabled" : "disabled"
  } } : {}

  # ndDom -> ndIf nested maps (VRF -> interfaces)
  nd_vrfs = { for vrf_name, vrf_data in try(local.nd_vrfs_by_device[each.key], {}) : vrf_name => {
    interfaces = { for int_id, nd in vrf_data.interfaces : int_id => {
      boot_file_url                  = try(nd.ra_boot_file_url, null)
      control                        = length(compact([for flag, value in local.nd_control_values : value if try({ "redirects" = nd.redirects, "managed_cfg" = nd.managed_config_flag, "other_cfg" = nd.other_config_flag, "suppress_ra" = nd.suppress_ra, "suppress_ra_mtu" = nd.suppress_ra_mtu }[flag], false)])) > 0 ? join(",", compact([for flag, value in local.nd_control_values : value if try({ "redirects" = nd.redirects, "managed_cfg" = nd.managed_config_flag, "other_cfg" = nd.other_config_flag, "suppress_ra" = nd.suppress_ra, "suppress_ra_mtu" = nd.suppress_ra_mtu }[flag], false)])) : null
      dad_attempts                   = try(nd.dad_attempts, null)
      dadns_interval                 = try(nd.dad_ns_interval, null)
      default_ra_lifetime            = try(nd.default_ra_lifetime, null) != null ? (nd.default_ra_lifetime ? "enabled" : "disabled") : null
      delete_adjacency_on_mac_delete = try(nd.delete_adjacency_on_mac_delete, null) != null ? (nd.delete_adjacency_on_mac_delete ? "enabled" : "disabled") : null
      dns_search_list_suppress       = try(nd.dns_search_list_suppress, null) != null ? (nd.dns_search_list_suppress ? "enabled" : "disabled") : null
      dns_suppress                   = try(nd.dns_suppress, null) != null ? (nd.dns_suppress ? "enabled" : "disabled") : null
      hop_limit                      = try(nd.hop_limit, null)
      mac_extract                    = try(nd.mac_extract, null)
      mtu                            = try(nd.mtu, null)
      neighbor_solicit_interval      = try(nd.ns_interval, null)
      ra_interval                    = try(nd.ra_interval, null)
      ra_interval_min                = try(nd.ra_interval_minimum, null)
      ra_lifetime                    = try(nd.ra_lifetime, null)
      reachable_time                 = try(nd.reachable_time, null)
      retransmit_timer               = try(nd.retrans_timer, null)
      route_suppress                 = try(nd.suppress_ra_route, null) != null ? (nd.suppress_ra_route ? "enabled" : "disabled") : null
      router_preference              = try(nd.router_preference, null)
    } }
  } }

  # datetimeClock attributes
  clock_format        = try(local.device_config[each.key].system.clock.format, null)
  clock_format_debug  = try(local.device_config[each.key].system.clock.format_show_timezone_debug, null)
  clock_format_syslog = try(local.device_config[each.key].system.clock.format_show_timezone_syslog, null)
  clock_protocol      = try(local.device_config[each.key].system.clock.protocol, null)

  # datetimeTimezone attributes
  clock_timezone_name    = try(local.device_config[each.key].system.clock.timezone_name, null)
  clock_timezone_hours   = try(local.device_config[each.key].system.clock.timezone_hours, null)
  clock_timezone_minutes = try(local.device_config[each.key].system.clock.timezone_minutes, null)

  # datetimeSummerT attributes
  clock_summer_time_name           = try(local.device_config[each.key].system.clock.summer_time.name, null)
  clock_summer_time_offset_minutes = try(local.device_config[each.key].system.clock.summer_time.offset_minutes, null)
  clock_summer_time_start_week     = try(local.device_config[each.key].system.clock.summer_time.start_week, null)
  clock_summer_time_start_day      = try(local.device_config[each.key].system.clock.summer_time.start_day, null)
  clock_summer_time_start_month    = try(local.device_config[each.key].system.clock.summer_time.start_month, null)
  clock_summer_time_start_time     = try(local.device_config[each.key].system.clock.summer_time.start_time, null)
  clock_summer_time_end_week       = try(local.device_config[each.key].system.clock.summer_time.end_week, null)
  clock_summer_time_end_day        = try(local.device_config[each.key].system.clock.summer_time.end_day, null)
  clock_summer_time_end_month      = try(local.device_config[each.key].system.clock.summer_time.end_month, null)
  clock_summer_time_end_time       = try(local.device_config[each.key].system.clock.summer_time.end_time, null)

  # bootBoot / bootImage attributes
  boot_auto_copy             = try(local.device_config[each.key].system.boot.auto_copy, null) == null ? null : (try(local.device_config[each.key].system.boot.auto_copy) ? "enable" : "disable")
  boot_dhcp                  = try(local.device_config[each.key].system.boot.dhcp, null)
  boot_exclude_configuration = try(local.device_config[each.key].system.boot.exclude_configuration, null) == null ? null : (try(local.device_config[each.key].system.boot.exclude_configuration) ? "enable" : "disable")
  boot_mode                  = try(local.device_config[each.key].system.boot.mode, null)
  boot_order                 = try(local.device_config[each.key].system.boot.order, null)
  boot_poap                  = try(local.device_config[each.key].system.boot.poap, null) == null ? null : (try(local.device_config[each.key].system.boot.poap) ? "enable" : "disable")
  boot_aci                   = try(local.device_config[each.key].system.boot.aci, null)
  boot_image_verification    = try(local.device_config[each.key].system.boot.image_verify, null) == null ? null : (try(local.device_config[each.key].system.boot.image_verify) ? "enable" : "disable")
  boot_image_supervisor_1    = try(local.device_config[each.key].system.boot.nxos_image_sup_1, null)
  boot_image_supervisor_2    = try(local.device_config[each.key].system.boot.nxos_image_sup_2, null)

  # cfsEntity / cfsInst attributes
  cfs_distribute             = try(local.device_config[each.key].system.cfs_distribute, null) == null ? null : (try(local.device_config[each.key].system.cfs_distribute) ? "enabled" : "disabled")
  cfs_ethernet_distribution  = try(local.device_config[each.key].system.cfs_eth_distribute, null) == null ? null : (try(local.device_config[each.key].system.cfs_eth_distribute) ? "enabled" : "disabled")
  cfs_ipv4_distribution      = try(local.device_config[each.key].system.cfs_ipv4_distribute, null) == null ? null : (try(local.device_config[each.key].system.cfs_ipv4_distribute) ? "enabled" : "disabled")
  cfs_ipv4_multicast_address = try(local.device_config[each.key].system.cfs_ipv4_mcast_address, null)
  cfs_ipv6_distribution      = try(local.device_config[each.key].system.cfs_ipv6_distribute, null) == null ? null : (try(local.device_config[each.key].system.cfs_ipv6_distribute) ? "enabled" : "disabled")
  cfs_ipv6_multicast_address = try(local.device_config[each.key].system.cfs_ipv6_mcast_address, null)

  # coppEntity / coppProfile attributes
  copp_rate_limiter = try(local.device_config[each.key].system.copp_rate_limit, null)
  copp_profile_type = try(local.device_config[each.key].system.copp_profile, null)

  # vshdCliAlias nested map
  cli_aliases = { for alias in try(local.device_config[each.key].system.cli_aliases, []) : alias.name => {
    command = try(alias.command, null)
  } }

  # licensemanagerSmartLicensing attributes
  smart_licensing_transport_mode     = try(local.smart_licensing_transport_map[try(local.device_config[each.key].system.smart_licensing_transport)], null)
  smart_licensing_transport_cslu_url = try(local.device_config[each.key].system.smart_licensing_url_cslu, null)

  # terminalTerminal attributes
  console_exec_timeout = try(local.device_config[each.key].system.terminal_console_exec_timeout, null)
  vty_exec_timeout     = try(local.device_config[each.key].system.line_vty_exec_timeout, null)
  vty_session_limit    = try(local.device_config[each.key].system.line_vty_session_limit, null)

  # icamEntity / icamInst / icamScale attributes
  icam_monitor_interval         = try(local.device_config[each.key].system.icam_monitor_interval, null)
  icam_number_of_intervals      = try(local.device_config[each.key].system.icam_monitor_intervals, null)
  icam_scale_configuration      = try(local.device_config[each.key].system.icam_monitor_scale, null)
  icam_scale_critical_threshold = try(local.device_config[each.key].system.icam_monitor_threshold_critical, null)
  icam_scale_info_threshold     = try(local.device_config[each.key].system.icam_monitor_threshold_info, null)
  icam_scale_warning_threshold  = try(local.device_config[each.key].system.icam_monitor_threshold_warning, null)

  # platformEntity attributes
  platform_access_list_match_inner_header            = try(local.device_config[each.key].system.platform.access_list_match_inner_header, null) == null ? null : (try(local.device_config[each.key].system.platform.access_list_match_inner_header) ? "enable" : "disable")
  platform_acl_tap_aggregation                       = try(local.device_config[each.key].system.platform.acl_tap_aggregation, null) == null ? null : (try(local.device_config[each.key].system.platform.acl_tap_aggregation) ? "enable" : "disable")
  platform_disable_parse_error                       = try(local.device_config[each.key].system.platform.disable_parse_error, null) == null ? null : (try(local.device_config[each.key].system.platform.disable_parse_error) ? "enable" : "disable")
  platform_global_tx_span                            = try(local.device_config[each.key].system.platform.global_tx_span, null) == null ? null : (try(local.device_config[each.key].system.platform.global_tx_span) ? "enable" : "disable")
  platform_high_multicast_priority                   = try(local.device_config[each.key].system.platform.high_multicast_priority, null) == null ? null : (try(local.device_config[each.key].system.platform.high_multicast_priority) ? "enabled" : "disabled")
  platform_hardware_lou_resource_threshold           = try(local.device_config[each.key].system.platform.hardware_lou_resource_threshold, null)
  platform_ingress_bd_ifacl_label_optimization       = try(local.device_config[each.key].system.platform.ingress_bd_ifacl_label_optimization, null) == null ? null : (try(local.device_config[each.key].system.platform.ingress_bd_ifacl_label_optimization) ? "enable" : "disable")
  platform_ingress_racl_size                         = try(local.device_config[each.key].system.platform.ingress_racl_size, null) == null ? null : (try(local.device_config[each.key].system.platform.ingress_racl_size) ? "enable" : "disable")
  platform_ingress_replication_round_robin           = try(local.device_config[each.key].system.platform.ingress_replication_round_robin, null)
  platform_ip_statistics                             = try(local.device_config[each.key].system.platform.ip_statistics, null) == null ? null : (try(local.device_config[each.key].system.platform.ip_statistics) ? "enable" : "disable")
  platform_ipv6_alpm_carve_value                     = try(local.device_config[each.key].system.platform.ipv6_alpm_carve_value, null)
  platform_ipv6_lpm_max_entries                      = try(local.device_config[each.key].system.platform.ipv6_lpm_max_entries, null)
  platform_lpm_max_limit                             = try(local.device_config[each.key].system.platform.lpm_max_limit, null)
  platform_multicast_dcs_check                       = try(local.device_config[each.key].system.platform.multicast_dcs_check, null) == null ? null : (try(local.device_config[each.key].system.platform.multicast_dcs_check) ? "enable" : "disable")
  platform_multicast_flex_stats                      = try(local.device_config[each.key].system.platform.multicast_flex_stats, null) == null ? null : (try(local.device_config[each.key].system.platform.multicast_flex_stats) ? "enable" : "disable")
  platform_multicast_lpm_max_entries                 = try(local.device_config[each.key].system.platform.multicast_lpm_max_entries, null)
  platform_multicast_max_limit                       = try(local.device_config[each.key].system.platform.multicast_max_limit, null)
  platform_multicast_nlb                             = try(local.device_config[each.key].system.platform.multicast_nlb, null) == null ? null : (try(local.device_config[each.key].system.platform.multicast_nlb) ? "enable" : "disable")
  platform_multicast_racl_bridge                     = try(local.device_config[each.key].system.platform.multicast_racl_bridge, null) == null ? null : (try(local.device_config[each.key].system.platform.multicast_racl_bridge) ? "enabled" : "disabled")
  platform_multicast_rpf_check_optimization          = try(local.device_config[each.key].system.platform.multicast_rpf_check_optimization, null) == null ? null : (try(local.device_config[each.key].system.platform.multicast_rpf_check_optimization) ? "enabled" : "disabled")
  platform_multicast_service_reflect_port            = try(local.device_config[each.key].system.platform.multicast_service_reflect_port, null)
  platform_multicast_syslog_threshold                = try(local.device_config[each.key].system.platform.multicast_syslog_threshold, null)
  platform_mld_snooping                              = try(local.device_config[each.key].system.platform.mld_snooping, null) == null ? null : (try(local.device_config[each.key].system.platform.mld_snooping) ? "enable" : "disable")
  platform_mpls_adjacency_stats_mode                 = try(local.device_config[each.key].system.platform.mpls_adjacency_stats_mode, null)
  platform_mpls_ecmp_mode                            = try(local.device_config[each.key].system.platform.mpls_ecmp, null) == null ? null : (try(local.device_config[each.key].system.platform.mpls_ecmp) ? "enable" : "disable")
  platform_mrouting_disable_l2_update                = try(local.device_config[each.key].system.platform.mrouting_disable_l2_update, null) == null ? null : (try(local.device_config[each.key].system.platform.mrouting_disable_l2_update) ? "enable" : "disable")
  platform_mrouting_disable_second_route_update      = try(local.device_config[each.key].system.platform.mrouting_disable_second_route_update, null) == null ? null : (try(local.device_config[each.key].system.platform.mrouting_disable_second_route_update) ? "enable" : "disable")
  platform_mrouting_performance_mode                 = try(local.device_config[each.key].system.platform.mrouting_performance_mode, null) == null ? null : (try(local.device_config[each.key].system.platform.mrouting_performance_mode) ? "enable" : "disable")
  platform_openflow_forward_pdu                      = try(local.device_config[each.key].system.platform.openflow_forward_pdu, null) == null ? null : (try(local.device_config[each.key].system.platform.openflow_forward_pdu) ? "enabled" : "disabled")
  platform_pbr_skip_self_ip                          = try(local.device_config[each.key].system.platform.pbr_skip_self_ip, null) == null ? null : (try(local.device_config[each.key].system.platform.pbr_skip_self_ip) ? "enabled" : "disabled")
  platform_pic_core_enable                           = try(local.device_config[each.key].system.platform.pic_core, null) == null ? null : (try(local.device_config[each.key].system.platform.pic_core) ? "enabled" : "disabled")
  platform_port_channel_fast_convergence             = try(local.device_config[each.key].system.platform.port_channel_fast_convergence, null) == null ? null : (try(local.device_config[each.key].system.platform.port_channel_fast_convergence) ? "enable" : "disable")
  platform_port_channel_load_balance_algorithm       = try(local.platform_pc_lb_algo_map[try(local.device_config[each.key].system.platform.port_channel_load_balance)], null)
  platform_port_channel_load_balance_resilient       = try(local.device_config[each.key].system.platform.port_channel_load_balance_resilient, null) == null ? null : (try(local.device_config[each.key].system.platform.port_channel_load_balance_resilient) ? "yes" : "no")
  platform_port_channel_mpls_load_balance_label_ip   = try(local.device_config[each.key].system.platform.port_channel_mpls_load_balance_label_ip, null) == null ? null : (try(local.device_config[each.key].system.platform.port_channel_mpls_load_balance_label_ip) ? "LABEL_IP" : "DEFAULT")
  platform_port_channel_mpls_load_balance_label_only = try(local.device_config[each.key].system.platform.port_channel_mpls_load_balance_label_only, null) == null ? null : (try(local.device_config[each.key].system.platform.port_channel_mpls_load_balance_label_only) ? "LABEL_ONLY" : "DEFAULT")
  platform_port_channel_scale_fanout                 = try(local.device_config[each.key].system.platform.port_channel_scale_fanout, null) == null ? null : (try(local.device_config[each.key].system.platform.port_channel_scale_fanout) ? "enable" : "disable")
  platform_profile_front_port_mode                   = try(local.device_config[each.key].system.platform.profile_front_portmode, null)
  platform_profile_mode                              = try(local.device_config[each.key].system.platform.profile_mode, null)
  platform_profile_tuple                             = try(local.device_config[each.key].system.platform.profile_tuple, null) == null ? null : (try(local.device_config[each.key].system.platform.profile_tuple) ? "Enable" : "Disable")
  platform_pstat_configuration                       = try(local.device_config[each.key].system.platform.pstat, null) == null ? null : (try(local.device_config[each.key].system.platform.pstat) ? "PSTAT_ENABLE" : "PSTAT_DISABLE")
  platform_qos_min_buffer                            = try(local.device_config[each.key].system.platform.qos_min_buffer, null)
  platform_routing_mode                              = try(local.device_config[each.key].system.platform.routing_mode, null)
  platform_service_template_name                     = try(local.device_config[each.key].system.platform.service_template_name, null)
  platform_svi_and_si_flex_stats                     = try(local.device_config[each.key].system.platform.svi_and_si_flex_stats, null) == null ? null : (try(local.device_config[each.key].system.platform.svi_and_si_flex_stats) ? "enable" : "disable")
  platform_svi_flex_stats                            = try(local.device_config[each.key].system.platform.svi_flex_stats, null) == null ? null : (try(local.device_config[each.key].system.platform.svi_flex_stats) ? "enable" : "disable")
  platform_switch_mode                               = try(local.device_config[each.key].system.platform.switch_mode, null)
  platform_switching_fabric_speed                    = try(local.device_config[each.key].system.platform.switching_fabric_speed, null)
  platform_switching_mode                            = try(local.platform_switching_mode_map[try(local.device_config[each.key].system.platform.switching_mode)], null)
  platform_system_fabric_mode                        = try(local.device_config[each.key].system.platform.system_fabric_mode, null)
  platform_tcam_syslog_threshold                     = try(local.device_config[each.key].system.platform.tcam_syslog_threshold, null)
  platform_unicast_max_limit                         = try(local.device_config[each.key].system.platform.unicast_max_limit, null)
  platform_unicast_syslog_threshold                  = try(local.device_config[each.key].system.platform.unicast_syslog_threshold, null)
  platform_unicast_trace                             = try(local.device_config[each.key].system.platform.unicast_trace, null) == null ? null : (try(local.device_config[each.key].system.platform.unicast_trace) ? "enable" : "disable")
  platform_unknown_unicast_flood                     = try(local.device_config[each.key].system.platform.unknown_unicast_flood, null) == null ? null : (try(local.device_config[each.key].system.platform.unknown_unicast_flood) ? "enabled" : "disabled")
  platform_urpf_status                               = try(local.device_config[each.key].system.platform.urpf, null) == null ? null : (try(local.device_config[each.key].system.platform.urpf) ? "enabled" : "disabled")
  platform_wrr_unicast_bandwidth                     = try(local.device_config[each.key].system.platform.wrr_unicast_bandwidth, null)

  # nwVdc nested map
  vdcs = { for vdc in try(local.device_config[each.key].system.vdcs, []) : vdc.id => {
    resource_limits = {
      multicast_ipv4_route_memory_maximum = try(vdc.resource_limits.multicast_ipv4_route_memory_maximum, null)
      multicast_ipv4_route_memory_minimum = try(vdc.resource_limits.multicast_ipv4_route_memory_minimum, null)
      multicast_ipv6_route_memory_maximum = try(vdc.resource_limits.multicast_ipv6_route_memory_maximum, null)
      multicast_ipv6_route_memory_minimum = try(vdc.resource_limits.multicast_ipv6_route_memory_minimum, null)
      port_channel_maximum                = try(vdc.resource_limits.port_channel_maximum, null)
      port_channel_minimum                = try(vdc.resource_limits.port_channel_minimum, null)
      unicast_ipv4_route_memory_maximum   = try(vdc.resource_limits.unicast_ipv4_route_memory_maximum, null)
      unicast_ipv4_route_memory_minimum   = try(vdc.resource_limits.unicast_ipv4_route_memory_minimum, null)
      unicast_ipv6_route_memory_maximum   = try(vdc.resource_limits.unicast_ipv6_route_memory_maximum, null)
      unicast_ipv6_route_memory_minimum   = try(vdc.resource_limits.unicast_ipv6_route_memory_minimum, null)
      vlan_maximum                        = try(vdc.resource_limits.vlan_maximum, null)
      vlan_minimum                        = try(vdc.resource_limits.vlan_minimum, null)
      vrf_maximum                         = try(vdc.resource_limits.vrf_maximum, null)
      vrf_minimum                         = try(vdc.resource_limits.vrf_minimum, null)
    }
  } }

  # mgmtMgmtIf nested map
  management_interfaces = { for int in try(local.device_config[each.key].interfaces.management, []) : int.id => {
    admin_state      = try(int.shutdown, false) ? "down" : "up"
    description      = try(int.description, null)
    duplex           = try(int.duplex, null)
    mtu              = try(int.mtu, null)
    speed            = try(int.speed, null)
    auto_negotiation = try(int.negotiation_auto, null)
    snmp_trap_state  = try(int.snmp_trap_link_status, null) == null ? null : (try(int.snmp_trap_link_status) ? "enable" : "disable")
  } }

  # cdpInst attributes
  cdp_transmit_frequency = try(local.device_config[each.key].cdp.timer, null)
  cdp_hold_interval      = try(local.device_config[each.key].cdp.holdtime, null)
  cdp_version            = try(local.device_config[each.key].cdp.advertise, null)
  cdp_device_id_type     = try(local.cdp_format_device_id_map[try(local.device_config[each.key].cdp.format_device_id)], null)
  cdp_pnp_startup_vlan   = try(local.device_config[each.key].cdp.pnp_startup_vlan, null)

  # cdpIf nested map
  cdp_interfaces = { for entry in try(local.cdp_interfaces_by_device[each.key], []) : entry.interface_id => {
    admin_state = entry.cdp ? "enabled" : "disabled"
  } }

  # dnsEntity attributes
  dns_admin_state = try(local.device_config[each.key].dns.domain_lookup, null) == null ? null : (try(local.device_config[each.key].dns.domain_lookup) ? "enabled" : "disabled")
  dns_profiles = try(local.device_config[each.key].dns.domain_name, null) != null ? {
    "default" = {
      domain_name = try(local.device_config[each.key].dns.domain_name, null)
    }
  } : {}

  # lldpInst attributes
  lldp_hold_time                   = try(local.device_config[each.key].lldp.holdtime, null)
  lldp_init_delay_time             = try(local.device_config[each.key].lldp.reinit, null)
  lldp_transmit_frequency          = try(local.device_config[each.key].lldp.timer, null)
  lldp_optional_tlv_select         = try(local.device_config[each.key].lldp.tlv_select, null)
  lldp_port_id_sub_type            = try(local.device_config[each.key].lldp.portid_subtype, null)
  lldp_advertise_system_chassis_id = try(local.device_config[each.key].lldp.chassis_id, null) == null ? null : (try(local.device_config[each.key].lldp.chassis_id) ? "enabled" : "disabled")
  lldp_port_channel                = try(local.device_config[each.key].lldp.portchannel, null) == null ? null : (try(local.device_config[each.key].lldp.portchannel) ? "enabled" : "disabled")

  # lldpIf nested map
  lldp_interfaces = { for entry in try(local.lldp_interfaces_by_device[each.key], []) : entry.interface_id => {
    admin_receive_state  = try(entry.lldp_receive, null) == null ? null : (entry.lldp_receive ? "enabled" : "disabled")
    admin_transmit_state = try(entry.lldp_transmit, null) == null ? null : (entry.lldp_transmit ? "enabled" : "disabled")
    port_dcbxp_version   = try(entry.lldp_dcbx_version, null)
    tlv_management_ipv4  = try(entry.lldp_tlv_set_management_address_v4, null)
    tlv_management_ipv6  = try(entry.lldp_tlv_set_management_address_v6, null)
    tlv_vlan             = try(entry.lldp_tlv_set_vlan, null)
  } }

  # udldInst attributes
  udld_aggressive       = try(local.device_config[each.key].udld.aggressive, null) == null ? null : (try(local.device_config[each.key].udld.aggressive) ? "enabled" : "disabled")
  udld_message_interval = try(local.device_config[each.key].udld.message_time, null)

  # udldPhysIf nested map
  udld_interfaces = { for entry in try(local.udld_interfaces_by_device[each.key], []) : entry.interface_id => {
    admin_state = try(entry.udld, null) == null ? null : (entry.udld ? "port-enabled" : "port-default")
    aggressive  = try(entry.udld_aggressive, null) == null ? null : (entry.udld_aggressive ? "enabled" : "disabled")
  } }

  # nxapiInst attributes
  nxapi_vrf                               = try(local.device_config[each.key].system.nxapi.vrf, null)
  nxapi_http_port                         = try(local.device_config[each.key].system.nxapi.http_port, null)
  nxapi_https_port                        = try(local.device_config[each.key].system.nxapi.https_port, null)
  nxapi_idle_timeout                      = try(local.device_config[each.key].system.nxapi.idle_timeout, null)
  nxapi_certificate_enable                = try(local.device_config[each.key].system.nxapi.certificate_enable, null) == null ? null : try(local.device_config[each.key].system.nxapi.certificate_enable)
  nxapi_certificate_file                  = try(local.device_config[each.key].system.nxapi.certificate_httpscrt, null)
  nxapi_key_file                          = try(local.device_config[each.key].system.nxapi.certificate_httpskey, null)
  nxapi_encrypted_key_passphrase          = try(local.device_config[each.key].system.nxapi.certificate_httpskey_passphrase, null)
  nxapi_trustpoint                        = try(local.device_config[each.key].system.nxapi.certificate_trustpoint, null)
  nxapi_ssl_protocols                     = try(local.device_config[each.key].system.nxapi.ssl_protocols, null)
  nxapi_ssl_ciphers_weak                  = try(local.device_config[each.key].system.nxapi.ssl_ciphers_weak, null) == null ? null : try(local.device_config[each.key].system.nxapi.ssl_ciphers_weak)
  nxapi_client_certificate_authentication = try(local.device_config[each.key].system.nxapi.client_cert_auth, null)
  nxapi_sudi                              = try(local.device_config[each.key].system.nxapi.sudi, null) == null ? null : try(local.device_config[each.key].system.nxapi.sudi)

  depends_on = [
    nxos_feature.feature,
    nxos_loopback_interface.loopback_interface,
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
    nxos_svi_interface.svi_interface,
    nxos_vrf.vrf,
  ]
}
