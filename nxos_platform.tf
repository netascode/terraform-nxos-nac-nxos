locals {
  platform_pc_lb_direction_map = {
    "src-dst" = "srcDst"
    "src"     = "src"
    "dst"     = "dst"
  }
  platform_pc_lb_fields_map = {
    "ip"             = "Ip"
    "ip-gre"         = "IpGre"
    "ip-l4port"      = "IpL4Port"
    "ip-l4port-vlan" = "IpL4PortVlan"
    "ip-vlan"        = "IpVlan"
    "l4port"         = "L4Port"
    "mac"            = "Mac"
    "inner-header"   = "Innerheader"
    "gtpu"           = "Gtpu"
  }
  platform_pc_lb_encapsulation_map = {
    "gre"             = "gre"
    "gtp"             = "gtp"
    "mpls-label-ip"   = "mpls"
    "mpls-label-only" = "mpls"
  }
  platform_pc_lb_algo_map = {
    "dlb"             = "PC_LB_ALGO_DLB"
    "rtag7"           = "PC_LB_ALGO_RTAG7"
    "rtag7-murmur"    = "PC_LB_ALGO_RTAG7_MURMUR"
    "rtag7-local-crc" = "PC_LB_ALGO_RTAG7_LOCAL_CRC"
    "dynamic-pin"     = "PC_LB_ALGO_DYNAMIC_PIN"
  }
  platform_mpls_adjacency_stats_mode_map = {
    "packets" = "PACKETS"
    "bytes"   = "BYTES"
  }
  platform_routing_map = {
    "non-hierarchical-routing"                    = "NON_HIER_DEFAULT"
    "non-hierarchical-routing-max-l3-mode"        = "NON_HIER_MAX_L3"
    "max-mode-host"                               = "MAX_HOST"
    "max-mode-tor-l3"                             = "TOR_MAX_L3"
    "mode-hierarchical-64b-alpm"                  = "DEFAULT_64B"
    "non-hierarchical-max-mode-l3-nh-64b-alpm-nh" = "NON_HIER_MAX_L3_64B"
    "hierarchical-def-max-mode-l3-64b-alpm"       = "TOR_MAX_L3_64B"
    "max-mode-tor-l2"                             = "TOR_MAX_L2"
    "max-mode-tor-l2-l3"                          = "TOR_MAX_L2L3"
    "template-overlay-host-scale"                 = "TOR_TEMPLATE_OVL_HOST_SCALE"
    "template-lpm-heavy"                          = "TEMPLATE_LPM_HEAVY"
    "template-lpm-scale-v6-64"                    = "TOR_TEMPLATE_LPM_SCALE_V6_64"
    "template-dual-stack-host-scale"              = "TOR_TEMPLATE_DUAL_STACK_HOST_SCALE"
    "template-service-provider"                   = "TEMPLATE_SERVICE_PROVIDER"
    "template-multicast-heavy"                    = "TEMPLATE_MULTICAST_HEAVY"
    "template-vxlan-scale"                        = "TEMPLATE_VXLAN_SCALE"
    "template-mpls-heavy"                         = "TEMPLATE_MPLS_SCALE"
    "template-internet-peering"                   = "TEMPLATE_INTERNET_PEERING"
    "template-multicast-ext-heavy"                = "TEMPLATE_MULTICAST_EXT_HEAVY"
    "template-l3-heavy"                           = "TEMPLATE_L3_HEAVY"
    "template-dual-stack-mcast"                   = "TEMPLATE_MULTICAST_DUAL_STACK"
    "template-l2-heavy"                           = "TEMPLATE_L2_HEAVY"
    "template-l2-scale"                           = "TEMPLATE_L2_SCALE"
    "template-security-groups"                    = "TEMPLATE_SECURITY_GROUPS"
  }
  platform_udf_offset_base_map = {
    "packet-start"    = "packet-start"
    "header-outer-l3" = "outer-header-l3"
    "header-outer-l4" = "outer-header-l4"
    "header-inner-l3" = "inner-header-l3"
    "header-inner-l4" = "inner-header-l4"
  }
}

resource "nxos_platform" "platform" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].system.hardware_profile, null) != null ||
    try(local.device_config[device.name].system.port_channel, null) != null ||
    try(local.device_config[device.name].system.switch_mode, null) != null ||
    try(local.device_config[device.name].system.fabric_mode, null) != null ||
    try(local.device_config[device.name].system.hardware, null) != null ||
    try(local.device_config[device.name].system.hardware_qos, null) != null ||
    try(local.device_config[device.name].system.hardware_access_list_tcam_region, null) != null ||
    try(local.device_config[device.name].system.nve_ipmc_index_size, null) != null ||
    try(local.device_config[device.name].system.nve_overlay_vlans, null) != null ||
    length(try(local.device_config[device.name].system.nve_infra_vlans, [])) > 0 ||
    try(local.device_config[device.name].system.dot1q_tunnel_transit_vlans, null) != null ||
    length(try(local.device_config[device.name].system.udfs, [])) > 0 ||
    try(local.device_config[device.name].qos.priority_flow_control, null) != null ||
  try(local.device_config[device.name].system.routing, null) != null }
  device = each.key

  # platformEntity attributes
  access_list_match_inner_header            = try(local.device_config[each.key].system.hardware_profile.access_list_match_inner_header, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.access_list_match_inner_header) ? "enable" : "disable")
  acl_tap_aggregation                       = try(local.device_config[each.key].system.hardware_profile.acl_tap_aggregation, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.acl_tap_aggregation) ? "enable" : "disable")
  dot1q_tunnel_transit_range                = try(provider::utils::normalize_vlans(try(local.device_config[each.key].system.dot1q_tunnel_transit_vlans), "string-nxos"), null)
  disable_parse_error                       = try(local.device_config[each.key].system.hardware_profile.disable_parse_error, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.disable_parse_error) ? "enable" : "disable")
  global_tx_span                            = try(local.device_config[each.key].system.hardware_profile.global_tx_span, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.global_tx_span) ? "enable" : "disable")
  high_multicast_priority                   = try(local.device_config[each.key].system.hardware_profile.high_multicast_priority, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.high_multicast_priority) ? "enabled" : "disabled")
  hardware_lou_resource_threshold           = try(local.device_config[each.key].system.hardware_profile.hardware_lou_resource_threshold, null)
  ingress_bd_ifacl_label_optimization       = try(local.device_config[each.key].system.hardware_profile.ingress_bd_ifacl_label_optimization, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.ingress_bd_ifacl_label_optimization) ? "enable" : "disable")
  ingress_racl_size                         = try(local.device_config[each.key].system.hardware_profile.ingress_racl_size, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.ingress_racl_size) ? "enable" : "disable")
  ingress_replication_round_robin           = try(local.device_config[each.key].system.hardware_profile.ingress_replication_round_robin, null)
  ip_statistics                             = try(local.device_config[each.key].system.hardware_profile.ip_statistics, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.ip_statistics) ? "enable" : "disable")
  ipv6_alpm_carve_value                     = try(local.device_config[each.key].system.hardware_profile.ipv6_alpm_carve_value, null)
  ipv6_lpm_max_entries                      = try(local.device_config[each.key].system.hardware_profile.ipv6_lpm_max_entries, null)
  lpm_max_limit                             = try(local.device_config[each.key].system.hardware_profile.lpm_max_limit, null)
  multicast_dcs_check                       = try(local.device_config[each.key].system.hardware_profile.multicast_dcs_check, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.multicast_dcs_check) ? "enable" : "disable")
  multicast_flex_stats                      = try(local.device_config[each.key].system.hardware_profile.multicast_flex_stats, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.multicast_flex_stats) ? "enable" : "disable")
  multicast_lpm_max_entries                 = try(local.device_config[each.key].system.hardware_profile.multicast_lpm_max_entries, null)
  multicast_max_limit                       = try(local.device_config[each.key].system.hardware_profile.multicast_max_limit, null)
  multicast_nlb                             = try(local.device_config[each.key].system.hardware_profile.multicast_nlb, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.multicast_nlb) ? "enable" : "disable")
  multicast_racl_bridge                     = try(local.device_config[each.key].system.hardware_profile.multicast_racl_bridge, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.multicast_racl_bridge) ? "enabled" : "disabled")
  multicast_rpf_check_optimization          = try(local.device_config[each.key].system.hardware_profile.multicast_rpf_check_optimization, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.multicast_rpf_check_optimization) ? "enabled" : "disabled")
  multicast_service_reflect_port            = try(local.device_config[each.key].system.hardware_profile.multicast_service_reflect_port, null)
  multicast_syslog_threshold                = try(local.device_config[each.key].system.hardware_profile.multicast_syslog_threshold, null)
  mld_snooping                              = try(local.device_config[each.key].system.hardware_profile.mld_snooping, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.mld_snooping) ? "enable" : "disable")
  mpls_adjacency_stats_mode                 = try(local.platform_mpls_adjacency_stats_mode_map[try(local.device_config[each.key].system.hardware_profile.mpls_adjacency_stats_mode)], try(local.device_config[each.key].system.hardware_profile.mpls_adjacency_stats_mode, null))
  mpls_ecmp_mode                            = try(local.device_config[each.key].system.hardware_profile.mpls_ecmp, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.mpls_ecmp) ? "enable" : "disable")
  mrouting_disable_l2_update                = try(local.device_config[each.key].system.hardware_profile.mrouting_disable_l2_update, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.mrouting_disable_l2_update) ? "enable" : "disable")
  mrouting_disable_second_route_update      = try(local.device_config[each.key].system.hardware_profile.mrouting_disable_second_route_update, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.mrouting_disable_second_route_update) ? "enable" : "disable")
  mrouting_performance_mode                 = try(local.device_config[each.key].system.hardware_profile.mrouting_performance_mode, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.mrouting_performance_mode) ? "enable" : "disable")
  openflow_forward_pdu                      = try(local.device_config[each.key].system.hardware_profile.flow_redirect_forward_pdu, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.flow_redirect_forward_pdu) ? "enabled" : "disabled")
  pbr_skip_self_ip                          = try(local.device_config[each.key].system.hardware_profile.pbr_skip_self_ip, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.pbr_skip_self_ip) ? "enabled" : "disabled")
  pic_core_enable                           = try(local.device_config[each.key].system.hardware_profile.pic_core, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.pic_core) ? "enabled" : "disabled")
  port_channel_fast_convergence             = try(local.device_config[each.key].system.port_channel.fast_convergence, null) == null ? null : (try(local.device_config[each.key].system.port_channel.fast_convergence) ? "enable" : "disable")
  port_channel_load_balance_algorithm       = try(local.platform_pc_lb_algo_map[try(local.device_config[each.key].system.port_channel.load_balance)], null)
  port_channel_load_balance_resilient       = try(local.device_config[each.key].system.port_channel.load_balance2_resilient, null) == null ? null : (try(local.device_config[each.key].system.port_channel.load_balance2_resilient) ? "yes" : "no")
  port_channel_mpls_load_balance_label_ip   = try(local.device_config[each.key].system.port_channel.load_balance_mpls_label_ip, null) == null ? null : (try(local.device_config[each.key].system.port_channel.load_balance_mpls_label_ip) ? "LABEL_IP" : "DEFAULT")
  port_channel_mpls_load_balance_label_only = try(local.device_config[each.key].system.port_channel.load_balance_mpls_label_only, null) == null ? null : (try(local.device_config[each.key].system.port_channel.load_balance_mpls_label_only) ? "LABEL_ONLY" : "DEFAULT")
  port_channel_scale_fanout                 = try(local.device_config[each.key].system.port_channel.scale_fanout, null) == null ? null : (try(local.device_config[each.key].system.port_channel.scale_fanout) ? "enable" : "disable")
  port_channel_load_balance_fields          = try(local.device_config[each.key].system.port_channel.load_balance_direction, null) == null && try(local.device_config[each.key].system.port_channel.load_balance_fields, null) == null ? null : "${local.platform_pc_lb_direction_map[try(local.device_config[each.key].system.port_channel.load_balance_direction, "src-dst")]}${local.platform_pc_lb_fields_map[try(local.device_config[each.key].system.port_channel.load_balance_fields, "ip-l4port")]}"
  port_channel_load_balance_encapsulation   = try(local.platform_pc_lb_encapsulation_map[try(local.device_config[each.key].system.port_channel.load_balance_encapsulation)], null)
  port_channel_load_balance_mpls_label_ip   = try(local.device_config[each.key].system.port_channel.load_balance_encapsulation, null) == null ? null : (try(local.device_config[each.key].system.port_channel.load_balance_encapsulation) == "mpls-label-ip" ? "enable" : "disable")
  port_channel_load_balance_mpls_label_only = try(local.device_config[each.key].system.port_channel.load_balance_encapsulation, null) == null ? null : (try(local.device_config[each.key].system.port_channel.load_balance_encapsulation) == "mpls-label-only" ? "enable" : "disable")
  port_channel_load_balance_rotate          = try(local.device_config[each.key].system.port_channel.load_balance_rotate, null)
  port_channel_load_balance_concatenation   = try(local.device_config[each.key].system.port_channel.load_balance_concatenation, null) == null ? null : (try(local.device_config[each.key].system.port_channel.load_balance_concatenation) ? "enable" : "disable")
  port_channel_load_balance_fex             = try(local.device_config[each.key].system.port_channel.load_balance_fex_all, null)
  port_channel_load_balance_symmetry        = try(local.device_config[each.key].system.port_channel.load_balance_symmetric, null) == null ? null : (try(local.device_config[each.key].system.port_channel.load_balance_symmetric) ? "enable" : "disable")
  profile_front_port_mode                   = try(local.device_config[each.key].system.hardware_profile.front_portmode, null)
  profile_mode                              = try(local.device_config[each.key].system.hardware_profile.forwarding_mode, null)
  profile_tuple                             = try(local.device_config[each.key].system.hardware_profile.portmode_tuple, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.portmode_tuple) ? "Enable" : "Disable")
  pstat_configuration                       = try(local.device_config[each.key].system.hardware_profile.pstat, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.pstat) ? "PSTAT_ENABLE" : "PSTAT_DISABLE")
  qos_min_buffer                            = try(local.device_config[each.key].system.hardware_profile.qos_min_buffer, null)
  routing_mode                              = try(local.platform_routing_map[try(local.device_config[each.key].system.routing)], null)
  service_template_name                     = try(local.device_config[each.key].system.hardware_profile.service_template_name, null)
  svi_and_si_flex_stats                     = try(local.device_config[each.key].system.hardware_profile.svi_and_si_flex_stats_enable, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.svi_and_si_flex_stats_enable) ? "enable" : "disable")
  svi_flex_stats                            = try(local.device_config[each.key].system.hardware_profile.svi_flex_stats, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.svi_flex_stats) ? "enable" : "disable")
  switch_mode                               = try(local.device_config[each.key].system.switch_mode, null)
  system_fabric_mode                        = try(local.device_config[each.key].system.fabric_mode, null)
  tcam_syslog_threshold                     = try(local.device_config[each.key].system.hardware_profile.tcam_syslog_threshold, null)
  unicast_max_limit                         = try(local.device_config[each.key].system.hardware_profile.unicast_max_limit, null)
  unicast_syslog_threshold                  = try(local.device_config[each.key].system.hardware_profile.unicast_syslog_threshold, null)
  unicast_trace                             = try(local.device_config[each.key].system.hardware_profile.unicast_trace, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.unicast_trace) ? "enable" : "disable")
  unknown_unicast_flood                     = try(local.device_config[each.key].system.hardware_profile.unknown_unicast_flood, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.unknown_unicast_flood) ? "enabled" : "disabled")
  urpf_status                               = try(local.device_config[each.key].system.hardware_profile.urpf, null) == null ? null : (try(local.device_config[each.key].system.hardware_profile.urpf) ? "enabled" : "disabled")
  wrr_unicast_bandwidth                     = try(local.device_config[each.key].system.hardware_profile.wrr_unicast_bandwidth, null)

  # platformEntityExtended attributes
  extended_acl_disable_redirect_share          = try(local.device_config[each.key].system.hardware.acl_redirect_share_disable, null) == null ? null : (try(local.device_config[each.key].system.hardware.acl_redirect_share_disable) ? "enable" : "disable")
  extended_atomic_update                       = try(local.device_config[each.key].system.hardware.access_list_update_atomic, null) == null ? null : (try(local.device_config[each.key].system.hardware.access_list_update_atomic) ? "enable" : "disable")
  extended_atomic_update_strict                = try(local.device_config[each.key].system.hardware.access_list_update_atomic_strict, null) == null ? null : (try(local.device_config[each.key].system.hardware.access_list_update_atomic_strict) ? "enable" : "disable")
  extended_counter_manager_bfd_scale           = try(local.device_config[each.key].system.hardware.counter_bfd_feature_scale, null)
  extended_counter_manager_ecn_scale           = try(local.device_config[each.key].system.hardware.counter_ecn_feature_scale, null)
  extended_counter_manager_egress_acl_scale    = try(local.device_config[each.key].system.hardware.counter_egr_acl_feature_scale, null)
  extended_counter_manager_feature_bfd         = try(local.device_config[each.key].system.hardware.counter_feature_bfd, null)
  extended_counter_manager_feature_ecn         = try(local.device_config[each.key].system.hardware.counter_feature_ecn, null)
  extended_counter_manager_feature_egress_acl  = try(local.device_config[each.key].system.hardware.counter_feature_egr_acl, null)
  extended_counter_manager_feature_ingress_acl = try(local.device_config[each.key].system.hardware.counter_feature_ingr_acl, null)
  extended_counter_manager_feature_l2vni       = try(local.device_config[each.key].system.hardware.counter_feature_l2vni, null)
  extended_counter_manager_feature_l3vni       = try(local.device_config[each.key].system.hardware.counter_feature_l3vni, null)
  extended_counter_manager_feature_si          = try(local.device_config[each.key].system.hardware.counter_feature_si, null)
  extended_counter_manager_feature_svi         = try(local.device_config[each.key].system.hardware.counter_feature_svi, null)
  extended_counter_manager_feature_tunnel      = try(local.device_config[each.key].system.hardware.counter_feature_tunnel, null)
  extended_counter_manager_feature_vlan        = try(local.device_config[each.key].system.hardware.counter_feature_vlan, null)
  extended_counter_manager_feature_voq         = try(local.device_config[each.key].system.hardware.counter_feature_voq, null)
  extended_counter_manager_ingress_acl_scale   = try(local.device_config[each.key].system.hardware.counter_ingr_acl_feature_scale, null)
  extended_counter_manager_l2vni_scale         = try(local.device_config[each.key].system.hardware.counter_l2vni_feature_scale, null)
  extended_counter_manager_l3vni_scale         = try(local.device_config[each.key].system.hardware.counter_l3vni_feature_scale, null)
  extended_counter_manager_si_scale            = try(local.device_config[each.key].system.hardware.counter_si_feature_scale, null)
  extended_counter_manager_svi_scale           = try(local.device_config[each.key].system.hardware.counter_svi_feature_scale, null)
  extended_counter_manager_tunnel_scale        = try(local.device_config[each.key].system.hardware.counter_tunnel_feature_scale, null)
  extended_counter_manager_vlan_scale          = try(local.device_config[each.key].system.hardware.counter_vlan_feature_scale, null)
  extended_counter_manager_voq_scale           = try(local.device_config[each.key].system.hardware.counter_voq_feature_scale, null)
  extended_dme_load_interval                   = try(local.device_config[each.key].system.hardware.dme_load_interval, null)
  extended_egress_l2_qos_ifacl_label_size      = try(local.device_config[each.key].system.hardware.egr_l2_qos_ifacl_label_size, null) == null ? null : (try(local.device_config[each.key].system.hardware.egr_l2_qos_ifacl_label_size) ? "enable" : "disable")
  extended_gpe5_timer_enable                   = try(local.device_config[each.key].system.hardware.gpe_5_timer_enable, null)
  extended_ingress_pacl_ifacl_label_size       = try(local.device_config[each.key].system.hardware.ing_ifacl_label_size, null) == null ? null : (try(local.device_config[each.key].system.hardware.ing_ifacl_label_size) ? "enable" : "disable")
  extended_ingress_vrf_nat_bd_label_width      = try(local.device_config[each.key].system.hardware.vrf_nat_label_width, null)
  extended_mpls_qos_pipe_mode                  = try(local.device_config[each.key].system.hardware.mpls_qos_pipe_mode, null) == null ? null : (try(local.device_config[each.key].system.hardware.mpls_qos_pipe_mode) ? "enabled" : "disabled")
  extended_multicast_nlb_stick_port_channel    = try(local.device_config[each.key].system.hardware.multicast_nlb_port_channel, null) == null ? null : (try(local.device_config[each.key].system.hardware.multicast_nlb_port_channel) ? "enable" : "disable")
  extended_multicast_priority                  = try(local.device_config[each.key].system.hardware.multicast_priority, null)
  extended_multicast_stats_disable             = try(local.device_config[each.key].system.hardware.multicast_stats_disable, null) == null ? null : (try(local.device_config[each.key].system.hardware.multicast_stats_disable) ? "enable" : "disable")
  extended_pbr_ecmp_paths                      = try(local.device_config[each.key].system.hardware.pbr_ecmp_paths, null)
  extended_pbr_fast_convergence                = try(local.device_config[each.key].system.hardware.pbr_next_hop_fast_convergence, null) == null ? null : (try(local.device_config[each.key].system.hardware.pbr_next_hop_fast_convergence) ? "enable" : "disable")
  extended_pbr_match_default_route             = try(local.device_config[each.key].system.hardware.pbr_match_default_route, null) == null ? null : (try(local.device_config[each.key].system.hardware.pbr_match_default_route) ? "enable" : "disable")
  extended_si_flex_stats                       = try(local.device_config[each.key].system.hardware.sub_interface_flex_stats, null)
  extended_stats_template                      = try(local.device_config[each.key].system.hardware.access_list_tcam_per_entry_stats_template, null)
  extended_storm_control_priority              = try(local.device_config[each.key].system.hardware.storm_control_priority, null)
  extended_tcam_default_result                 = try(local.device_config[each.key].system.hardware.access_list_update_default_result, null) == null ? null : (try(local.device_config[each.key].system.hardware.access_list_update_default_result) ? "enable" : "disable")
  extended_vrf_aware_nat_enable                = try(local.device_config[each.key].system.hardware.vrf_aware_nat_enable, null) == null ? null : (try(local.device_config[each.key].system.hardware.vrf_aware_nat_enable) ? "enabled" : "disabled")

  # platformPriorFlowCtrlWd attributes
  pfc_watchdog_auto_restore_multiplier       = try(local.device_config[each.key].qos.priority_flow_control.auto_restore_multiplier, null)
  pfc_watchdog_fixed_restore_multiplier      = try(local.device_config[each.key].qos.priority_flow_control.fixed_restore_multiplier, null)
  pfc_watchdog_forced_on                     = try(local.device_config[each.key].qos.priority_flow_control.watch_dog_forced, null) == null ? null : (try(local.device_config[each.key].qos.priority_flow_control.watch_dog_forced) ? "on" : "off")
  pfc_watchdog_internal_interface_multiplier = try(local.device_config[each.key].qos.priority_flow_control.watch_dog_internal_interface_multiplier, null)
  pfc_watchdog_interval                      = try(local.device_config[each.key].qos.priority_flow_control.watch_dog_interval_value, null)
  pfc_watchdog_mode                          = try(local.device_config[each.key].qos.priority_flow_control.watch_dog_interval, null) == null ? null : (try(local.device_config[each.key].qos.priority_flow_control.watch_dog_interval) ? "on" : "off")
  pfc_watchdog_shutdown_multiplier           = try(local.device_config[each.key].qos.priority_flow_control.watch_dog_shutdown_multiplier, null)

  # platformQos attributes
  qos_buffer_peak_monitor_counter0_class0 = try(local.device_config[each.key].system.hardware_qos.buffer_peak_monitor_counter0_classes, null) == null ? null : (contains(try(local.device_config[each.key].system.hardware_qos.buffer_peak_monitor_counter0_classes), 0) ? "configure" : "unconfigure")
  qos_buffer_peak_monitor_counter0_class1 = try(local.device_config[each.key].system.hardware_qos.buffer_peak_monitor_counter0_classes, null) == null ? null : (contains(try(local.device_config[each.key].system.hardware_qos.buffer_peak_monitor_counter0_classes), 1) ? "configure" : "unconfigure")
  qos_buffer_peak_monitor_counter0_class2 = try(local.device_config[each.key].system.hardware_qos.buffer_peak_monitor_counter0_classes, null) == null ? null : (contains(try(local.device_config[each.key].system.hardware_qos.buffer_peak_monitor_counter0_classes), 2) ? "configure" : "unconfigure")
  qos_buffer_peak_monitor_counter0_class3 = try(local.device_config[each.key].system.hardware_qos.buffer_peak_monitor_counter0_classes, null) == null ? null : (contains(try(local.device_config[each.key].system.hardware_qos.buffer_peak_monitor_counter0_classes), 3) ? "configure" : "unconfigure")
  qos_buffer_peak_monitor_counter0_class4 = try(local.device_config[each.key].system.hardware_qos.buffer_peak_monitor_counter0_classes, null) == null ? null : (contains(try(local.device_config[each.key].system.hardware_qos.buffer_peak_monitor_counter0_classes), 4) ? "configure" : "unconfigure")
  qos_buffer_peak_monitor_counter0_class5 = try(local.device_config[each.key].system.hardware_qos.buffer_peak_monitor_counter0_classes, null) == null ? null : (contains(try(local.device_config[each.key].system.hardware_qos.buffer_peak_monitor_counter0_classes), 5) ? "configure" : "unconfigure")
  qos_buffer_peak_monitor_counter0_class6 = try(local.device_config[each.key].system.hardware_qos.buffer_peak_monitor_counter0_classes, null) == null ? null : (contains(try(local.device_config[each.key].system.hardware_qos.buffer_peak_monitor_counter0_classes), 6) ? "configure" : "unconfigure")
  qos_buffer_peak_monitor_counter0_class7 = try(local.device_config[each.key].system.hardware_qos.buffer_peak_monitor_counter0_classes, null) == null ? null : (contains(try(local.device_config[each.key].system.hardware_qos.buffer_peak_monitor_counter0_classes), 7) ? "configure" : "unconfigure")
  qos_burst_detect_fall_threshold_unit    = try(local.device_config[each.key].system.hardware_qos.burst_detect_fall_threshold_unit, null) == null ? null : (try(local.device_config[each.key].system.hardware_qos.burst_detect_fall_threshold_unit) == "percent" ? "percentage" : try(local.device_config[each.key].system.hardware_qos.burst_detect_fall_threshold_unit))
  qos_burst_detect_fall_threshold         = try(local.device_config[each.key].system.hardware_qos.burst_detect_fall_threshold, null)
  qos_burst_detect_max_records            = try(local.device_config[each.key].system.hardware_qos.burst_detect_max_records, null)
  qos_burst_detect_rise_threshold_unit    = try(local.device_config[each.key].system.hardware_qos.burst_detect_rise_threshold_unit, null) == null ? null : (try(local.device_config[each.key].system.hardware_qos.burst_detect_rise_threshold_unit) == "percent" ? "percentage" : try(local.device_config[each.key].system.hardware_qos.burst_detect_rise_threshold_unit))
  qos_burst_detect_rise_threshold         = try(local.device_config[each.key].system.hardware_qos.burst_detect_rise_threshold, null)
  qos_classify_ns_only                    = try(local.device_config[each.key].system.hardware_qos.classify_ns_only, null) == null ? null : (try(local.device_config[each.key].system.hardware_qos.classify_ns_only) ? "Enabled" : "Disabled")
  qos_cpu_size                            = try(local.device_config[each.key].system.hardware_qos.cpu_pg_size, null)
  qos_dpp_age_period                      = try(local.device_config[each.key].system.hardware_qos.dynamic_packet_prioritization_age_period, null)
  qos_dpp_max_packets                     = try(local.device_config[each.key].system.hardware_qos.dynamic_packet_prioritization_max_num_pkts, null)
  qos_drop_pool_size                      = try(local.device_config[each.key].system.hardware_qos.pool_drop_size, null)
  qos_eoq_stats_class                     = try(local.device_config[each.key].system.hardware_qos.eoq_stats_class_qos_group, null) == null ? null : tostring(try(local.device_config[each.key].system.hardware_qos.eoq_stats_class_qos_group))
  qos_etrap_age_period                    = try(local.device_config[each.key].system.hardware_qos.etrap_age_period, null)
  qos_etrap_bandwidth_threshold           = try(local.device_config[each.key].system.hardware_qos.etrap_bandwidth_threshold, null)
  qos_etrap_byte_count                    = try(local.device_config[each.key].system.hardware_qos.etrap_byte_count, null)
  qos_headroom_size                       = try(local.device_config[each.key].system.hardware_qos.pool_headroom_size, null)
  qos_input_buffer_peak                   = try(local.device_config[each.key].system.hardware_qos.buffer_input_peak, null)
  qos_include_ipg                         = try(local.device_config[each.key].system.hardware_qos.include_ipg, null) == null ? null : (try(local.device_config[each.key].system.hardware_qos.include_ipg) ? "Enabled" : "Disabled")
  qos_lcpu_size                           = try(local.device_config[each.key].system.hardware_qos.lcpu_pg_size, null)
  qos_mac_ipg                             = try(local.device_config[each.key].system.hardware_qos.mac_ipg, null)
  qos_multicast_qos_group3_traffic        = try(local.device_config[each.key].system.hardware_qos.ns_mcq3_alias_qos_group, null) == null ? null : tostring(try(local.device_config[each.key].system.hardware_qos.ns_mcq3_alias_qos_group))
  qos_nodrop_dynamic_queue_limit          = try(local.device_config[each.key].system.hardware_qos.nodrop_pause_dynamic_q_limit, null)
  qos_nodrop_resume_offset                = try(local.device_config[each.key].system.hardware_qos.nodrop_pause_resume_offset, null)
  qos_nodrop_pg_green_threshold           = try(local.device_config[each.key].system.hardware_qos.nodrop_pg_thresholds_green_threshold, null)
  qos_nodrop_pg_red_threshold             = try(local.device_config[each.key].system.hardware_qos.nodrop_pg_thresholds_red_threshold, null)
  qos_nodrop_pg_size                      = try(local.device_config[each.key].system.hardware_qos.nodrop_pg_thresholds_pg_size, null)
  qos_nodrop_pg_size_fx                   = try(local.device_config[each.key].system.hardware_qos.nodrop_pg_thresholds_fx_pg_size, null)
  qos_nodrop_pg_yellow_threshold          = try(local.device_config[each.key].system.hardware_qos.nodrop_pg_thresholds_yellow_threshold, null)
  qos_nodrop_pool_size                    = try(local.device_config[each.key].system.hardware_qos.pool_nodrop_size, null)
  qos_nodrop_queue_green_threshold        = try(local.device_config[each.key].system.hardware_qos.nodrop_queue_thresholds_queue_green, null)
  qos_nodrop_queue_green_threshold_fx     = try(local.device_config[each.key].system.hardware_qos.nodrop_queue_thresholds_fx_queue_green, null)
  qos_nodrop_queue_yellow_threshold       = try(local.device_config[each.key].system.hardware_qos.nodrop_queue_thresholds_queue_yellow, null)
  qos_ns_buffer_profile                   = try(local.device_config[each.key].system.hardware_qos.ns_buffer_profile, null)
  qos_output_queue_drops_type             = try(local.device_config[each.key].system.hardware_qos.oq_drops_type, null)
  qos_pfc_multicast_drop                  = try(local.device_config[each.key].system.hardware_qos.pfc_mc_drop, null) == null ? null : (try(local.device_config[each.key].system.hardware_qos.pfc_mc_drop) ? "Enabled" : "Disabled")
  qos_pfc_static                          = try(local.device_config[each.key].system.hardware_qos.pfc_static, null) == null ? null : (try(local.device_config[each.key].system.hardware_qos.pfc_static) ? "Enabled" : "Disabled")
  qos_pg_headroom_reserve                 = try(local.device_config[each.key].system.hardware_qos.ing_pg_hdrm_reserve_percent, null)
  qos_pg_min_value                        = try(local.device_config[each.key].system.hardware_qos.ing_pg_no_min_pgmin, null)
  qos_pg_no_min                           = try(local.device_config[each.key].system.hardware_qos.ing_pg_no_min, null)
  qos_pg_share                            = try(local.device_config[each.key].system.hardware_qos.ing_pg_share, null) == null ? null : (try(local.device_config[each.key].system.hardware_qos.ing_pg_share) ? "Enabled" : "Disabled")
  qos_queue_noise_percent                 = try(local.device_config[each.key].system.hardware_qos.q_noise_percent, null)
  qos_afd_profile                         = try(local.device_config[each.key].system.hardware_qos.afd_profile, null)
  qos_span_size                           = try(local.device_config[each.key].system.hardware_qos.span_pg_size, null)

  # platformNVE / platformInfraVlan nested maps
  nve_interfaces = (try(local.device_config[each.key].system.nve_ipmc_index_size, null) != null ||
    try(local.device_config[each.key].system.nve_overlay_vlans, null) != null ||
    length(try(local.device_config[each.key].system.nve_infra_vlans, [])) > 0) ? {
    "1" = {
      ipmc_index_size = try(local.device_config[each.key].system.nve_ipmc_index_size, null)
      overlay_vlan_id = try(provider::utils::normalize_vlans(try(local.device_config[each.key].system.nve_overlay_vlans), "string-nxos"), null)
      infra_vlans = length(try(local.device_config[each.key].system.nve_infra_vlans, [])) > 0 ? merge([for group in try(local.device_config[each.key].system.nve_infra_vlans, []) : {
        for vlan_id in try(provider::utils::normalize_vlans(group.vlans, "list"), []) :
        tostring(vlan_id) => {
          force = try(group.force, null) == null ? null : (try(group.force) ? "Enable" : "Disable")
        }
      }]...) : null
    }
  } : null

  # platformTcamTemplate / platformUdfTcamTemplate nested maps
  tcam_templates = length(try(local.device_config[each.key].system.hardware_profile.tcam_resource_templates, [])) > 0 ? { for template in try(local.device_config[each.key].system.hardware_profile.tcam_resource_templates, []) : template.name => {
    reference_template = try(template.ref_template, null)
    udfs = length(flatten([for region in try(template.regions, []) : try(region.qualify_udfs, [])])) > 0 ? merge([for region in try(template.regions, []) : {
      for udf in try(region.qualify_udfs, []) : "${region.name};${udf}" => {}
    }]...) : null
  } } : null

  # platformUdfEntity / platformUdf nested map
  udfs = length(try(local.device_config[each.key].system.udfs, [])) > 0 ? { for udf in try(local.device_config[each.key].system.udfs, []) : udf.name => {
    mpls_stack_1 = try(udf.mpls, null) == null ? null : try(udf.mpls) == "stack1"
    mpls_stack_2 = try(udf.mpls, null) == null ? null : try(udf.mpls) == "stack2"
    # NX-OS has no negated "udf <name> netflow-rtp" form, and sending netflowRtp at all (even "no") renders "udf <name> netflow-rtp"
    netflow_rtp        = try(udf.netflow_rtp, false) ? true : null
    offset_base        = try(local.platform_udf_offset_base_map[try(udf.offset_base)], null)
    offset_length      = try(udf.length, null)
    offset_position    = try(udf.offset, null)
    qualify_ifacl      = try(udf.qualify_ifacl, null)
    qualify_ipv6_racl  = try(udf.qualify_ipv6_racl, null)
    qualify_racl       = try(udf.qualify_racl, null)
    qualify_racl_all   = try(udf.qualify_racl_all, null)
    qualify_span       = try(udf.qualify_span, null)
    qualify_span_all   = try(udf.qualify_span_all, null)
    qualify_span_v6    = try(udf.qualify_spanv6, null)
    qualify_span_v6_l2 = try(udf.qualify_spanv6_l2, null)
    qualify_vacl       = try(udf.qualify_vacl, null)
  } } : null

  # platformTcamRegion attributes
  tcam_region_arp_acl_size               = try(local.device_config[each.key].system.hardware_access_list_tcam_region.arp_acl_size, null)
  tcam_region_copp_size                  = try(local.device_config[each.key].system.hardware_access_list_tcam_region.copp_size, null)
  tcam_region_egress_ipv6_qos_size       = try(local.device_config[each.key].system.hardware_access_list_tcam_region.e_ipv6_qos_size, null)
  tcam_region_egress_ipv6_racl_size      = try(local.device_config[each.key].system.hardware_access_list_tcam_region.e_ipv6_racl_size, null)
  tcam_region_egress_mac_qos_size        = try(local.device_config[each.key].system.hardware_access_list_tcam_region.e_mac_qos_size, null)
  tcam_region_egress_qos_lite_size       = try(local.device_config[each.key].system.hardware_access_list_tcam_region.e_qos_lite_size, null)
  tcam_region_egress_qos_size            = try(local.device_config[each.key].system.hardware_access_list_tcam_region.e_qos_size, null)
  tcam_region_egress_racl_size           = try(local.device_config[each.key].system.hardware_access_list_tcam_region.e_racl_size, null)
  tcam_region_egress_vacl_size           = try(local.device_config[each.key].system.hardware_access_list_tcam_region.egress_vacl_size, null)
  tcam_region_fcoe_egress_size           = try(local.device_config[each.key].system.hardware_access_list_tcam_region.fcoe_egress_size, null)
  tcam_region_fcoe_ingress_size          = try(local.device_config[each.key].system.hardware_access_list_tcam_region.fcoe_ingress_size, null)
  tcam_region_fhs_size                   = try(local.device_config[each.key].system.hardware_access_list_tcam_region.fhs_size, null)
  tcam_region_interface_acl_lite_size    = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ifacl_lite_size, null)
  tcam_region_interface_acl_size         = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ifacl_size, null)
  tcam_region_interface_acl_udf_size     = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ifacl_udf_size, null)
  tcam_region_ingress_flow_redirect_size = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_flow_redirect_size, null)
  tcam_region_ingress_flow_size          = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_flow_size, null)
  tcam_region_ipsg_size                  = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ipsg_size, null)
  tcam_region_ipv6_interface_acl_size    = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ipv6_ifacl_size, null)
  tcam_region_ipv6_l3_qos_size           = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ipv6_l3_qos_size, null)
  tcam_region_ipv6_pbr_size              = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ipv6_pbr_size, null)
  tcam_region_ipv6_qos_size              = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ipv6_qos_size, null)
  tcam_region_ipv6_racl_size             = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ipv6_racl_size, null)
  tcam_region_ipv6_span_l2_size          = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ipv6_span_l2_size, null)
  tcam_region_ipv6_span_size             = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ipv6_span_size, null)
  tcam_region_ipv6_sup_size              = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ipv6_sup_size, null)
  tcam_region_ipv6_vacl_size             = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ipv6_vacl_size, null)
  tcam_region_ipv6_vlan_qos_size         = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ipv6_vqos_size, null)
  tcam_region_l3_qos_intra_lite_size     = try(local.device_config[each.key].system.hardware_access_list_tcam_region.l3qos_intra_lite_size, null)
  tcam_region_mac_interface_acl_size     = try(local.device_config[each.key].system.hardware_access_list_tcam_region.mac_ifacl_size, null)
  tcam_region_mac_l3_qos_size            = try(local.device_config[each.key].system.hardware_access_list_tcam_region.mac_l3_qos_size, null)
  tcam_region_mac_qos_size               = try(local.device_config[each.key].system.hardware_access_list_tcam_region.mac_qos_size, null)
  tcam_region_mac_vacl_size              = try(local.device_config[each.key].system.hardware_access_list_tcam_region.mac_vacl_size, null)
  tcam_region_mac_vlan_qos_size          = try(local.device_config[each.key].system.hardware_access_list_tcam_region.mac_vqos_size, null)
  tcam_region_multicast_bidir_size       = try(local.device_config[each.key].system.hardware_access_list_tcam_region.mcast_bidir_size, null)
  tcam_region_mpls_doublewide            = try(local.device_config[each.key].system.hardware_access_list_tcam_region.mpls_double_wide, null)
  tcam_region_mpls_size                  = try(local.device_config[each.key].system.hardware_access_list_tcam_region.mpls_size, null)
  tcam_region_mvpn_size                  = try(local.device_config[each.key].system.hardware_access_list_tcam_region.mvpn_size, null)
  tcam_region_n9k_arp_acl_size           = try(local.device_config[each.key].system.hardware_access_list_tcam_region.arp_ether_size, null)
  tcam_region_nat_size                   = try(local.device_config[each.key].system.hardware_access_list_tcam_region.nat_size, null)
  tcam_region_openflow_doublewide        = try(local.device_config[each.key].system.hardware_access_list_tcam_region.openflow_double_wide, null)
  tcam_region_openflow_lite_size         = try(local.device_config[each.key].system.hardware_access_list_tcam_region.openflow_lite_size, null)
  tcam_region_openflow_size              = try(local.device_config[each.key].system.hardware_access_list_tcam_region.openflow_size, null)
  tcam_region_pbr_size                   = try(local.device_config[each.key].system.hardware_access_list_tcam_region.pbr_size, null)
  tcam_region_qos_intra_lite_size        = try(local.device_config[each.key].system.hardware_access_list_tcam_region.qos_intra_lite_size, null)
  tcam_region_qos_size                   = try(local.device_config[each.key].system.hardware_access_list_tcam_region.qos_size, null)
  tcam_region_racl_lite_size             = try(local.device_config[each.key].system.hardware_access_list_tcam_region.racl_lite_size, null)
  tcam_region_racl_size                  = try(local.device_config[each.key].system.hardware_access_list_tcam_region.racl_size, null)
  tcam_region_racl_udf_size              = try(local.device_config[each.key].system.hardware_access_list_tcam_region.racl_udf_size, null)
  tcam_region_sup_size                   = try(local.device_config[each.key].system.hardware_access_list_tcam_region.sup_size, null)
  tcam_region_svi_size                   = try(local.device_config[each.key].system.hardware_access_list_tcam_region.svi_size, null)
  tcam_region_tcp_nat_size               = try(local.device_config[each.key].system.hardware_access_list_tcam_region.tcp_nat_size, null)
  tcam_region_vacl_lite_size             = try(local.device_config[each.key].system.hardware_access_list_tcam_region.vacl_lite_size, null)
  tcam_region_vacl_size                  = try(local.device_config[each.key].system.hardware_access_list_tcam_region.vacl_size, null)
  tcam_region_vpc_convergence_size       = try(local.device_config[each.key].system.hardware_access_list_tcam_region.vpc_convergence_size, null)
  tcam_region_vlan_qos_intra_lite_size   = try(local.device_config[each.key].system.hardware_access_list_tcam_region.vqos_intra_lite_size, null)
  tcam_region_vlan_qos_size              = try(local.device_config[each.key].system.hardware_access_list_tcam_region.vqos_size, null)
  tcam_region_vxlan_p2p_size             = try(local.device_config[each.key].system.hardware_access_list_tcam_region.vxlan_p2p_size, null)

  # platformTcamRegionExtended attributes
  tcam_region_extended_egress_interface_acl_all_per_port_stats = try(local.device_config[each.key].system.hardware_access_list_tcam_region.e_ifacl_all_per_port_stats, null)
  tcam_region_extended_egress_interface_acl_all_size           = try(local.device_config[each.key].system.hardware_access_list_tcam_region.e_ifacl_all_size, null)
  tcam_region_extended_egress_ipv6_racl_per_port_stats         = try(local.device_config[each.key].system.hardware_access_list_tcam_region.e_ipv6_racl_per_port_stats, null)
  tcam_region_extended_egress_racl_per_port_stats              = try(local.device_config[each.key].system.hardware_access_list_tcam_region.e_racl_per_port_stats, null)
  tcam_region_extended_egress_copp_size                        = try(local.device_config[each.key].system.hardware_access_list_tcam_region.egr_copp_size, null)
  tcam_region_extended_egress_flow_size                        = try(local.device_config[each.key].system.hardware_access_list_tcam_region.egr_flow_size, null)
  tcam_region_extended_egress_hardware_telemetry_size          = try(local.device_config[each.key].system.hardware_access_list_tcam_region.e_hw_telemetry_size, null)
  tcam_region_extended_egress_interface_acl_size               = try(local.device_config[each.key].system.hardware_access_list_tcam_region.egr_ifacl_size, null)
  tcam_region_extended_egress_l2_qos_size                      = try(local.device_config[each.key].system.hardware_access_list_tcam_region.egr_l2_qos_size, null)
  tcam_region_extended_egress_l3_vlan_qos_size                 = try(local.device_config[each.key].system.hardware_access_list_tcam_region.egr_l3_vlan_qos_size, null)
  tcam_region_extended_egress_racl_size                        = try(local.device_config[each.key].system.hardware_access_list_tcam_region.egr_racl_size, null)
  tcam_region_extended_egress_sup_size                         = try(local.device_config[each.key].system.hardware_access_list_tcam_region.egr_sup_size, null)
  tcam_region_extended_hardware_telemetry_size                 = try(local.device_config[each.key].system.hardware_access_list_tcam_region.hw_telemetry_size, null)
  tcam_region_extended_interface_acl_all_per_port_stats        = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ifacl_all_per_port_stats, null)
  tcam_region_extended_interface_acl_all_profile               = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ifacl_all_profile, null)
  tcam_region_extended_interface_acl_all_size                  = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ifacl_all_size, null)
  tcam_region_extended_interface_acl_per_port_stats            = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ifacl_per_port_stats, null)
  tcam_region_extended_ingress_dacl_size                       = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_dacl_size, null)
  tcam_region_extended_ingress_interface_acl_size              = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_ifacl_size, null)
  tcam_region_extended_ingress_interface_acl_wide_size         = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_ifacl_wide_size, null)
  tcam_region_extended_ingress_ipv6_interface_acl_lite_size    = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_ipv6_ifacl_lite_size, null)
  tcam_region_extended_ingress_l2_l3_qos_size                  = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_l2_l3_qos_size, null)
  tcam_region_extended_ingress_l2_qos_size                     = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_l2_qos_size, null)
  tcam_region_extended_ingress_l2_span_filter_size             = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_l2_span_filter_size, null)
  tcam_region_extended_ingress_l3_span_filter_size             = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_l3_span_filter_size, null)
  tcam_region_extended_ingress_pacl_sb_size                    = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_pacl_sb_size, null)
  tcam_region_extended_ingress_racl_size                       = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_racl_size, null)
  tcam_region_extended_ingress_rbacl_size                      = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_rbacl_size, null)
  tcam_region_extended_ingress_redirect_size                   = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_redirect_size, null)
  tcam_region_extended_ingress_storm_control_size              = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_storm_control_size, null)
  tcam_region_extended_ingress_sup_size                        = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_sup_size, null)
  tcam_region_extended_ingress_vacl_nh_size                    = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_vacl_nh_size, null)
  tcam_region_extended_ingress_vlan_qos_size                   = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_vlan_qos_size, null)
  tcam_region_extended_ipv6_interface_acl_per_port_stats       = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ipv6_ifacl_per_port_stats, null)
  tcam_region_extended_ipv6_racl_per_port_stats                = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ipv6_racl_per_port_stats, null)
  tcam_region_extended_mac_interface_acl_per_port_stats        = try(local.device_config[each.key].system.hardware_access_list_tcam_region.mac_ifacl_per_port_stats, null)
  tcam_region_extended_multicast_nat_size                      = try(local.device_config[each.key].system.hardware_access_list_tcam_region.mcast_nat_size, null)
  tcam_region_extended_multicast_nbm_size                      = try(local.device_config[each.key].system.hardware_access_list_tcam_region.mcast_nbm_size, null)
  tcam_region_extended_racl_all_per_port_stats                 = try(local.device_config[each.key].system.hardware_access_list_tcam_region.racl_all_per_port_stats, null)
  tcam_region_extended_racl_all_profile                        = try(local.device_config[each.key].system.hardware_access_list_tcam_region.racl_all_profile, null)
  tcam_region_extended_racl_all_size                           = try(local.device_config[each.key].system.hardware_access_list_tcam_region.racl_all_size, null)
  tcam_region_extended_racl_per_port_stats                     = try(local.device_config[each.key].system.hardware_access_list_tcam_region.racl_per_port_stats, null)
  tcam_region_extended_redirect_v4_size                        = try(local.device_config[each.key].system.hardware_access_list_tcam_region.redirect_size, null)
  tcam_region_extended_span_size                               = try(local.device_config[each.key].system.hardware_access_list_tcam_region.span_size, null)

  depends_on = [
    nxos_cli.cli_pre_9,
    nxos_feature.feature,
  ]
}
