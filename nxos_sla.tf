locals {
  sla_history_filter_map = {
    "all"           = "All"
    "failures"      = "Failures"
    "none"          = "None"
    "overThreshold" = "OverThreshold"
  }
}

resource "nxos_sla" "sla" {
  for_each = { for device in local.devices : device.name => device
  if try(local.device_config[device.name].ip_sla, null) != null }
  device = each.key

  sender_logging_traps          = try(local.device_config[each.key].ip_sla.logging_traps, null)
  responder_admin_state         = try(local.device_config[each.key].ip_sla.responder.enable, null)
  twamp_responder_admin_state   = try(local.device_config[each.key].ip_sla.responder.twamp, null)
  twamp_responder_timeout       = try(local.device_config[each.key].ip_sla.responder.twamp_timeout, null)
  twamp_server_admin_state      = try(local.device_config[each.key].ip_sla.server_twamp, null)
  twamp_server_inactivity_timer = try(local.device_config[each.key].ip_sla.server_twamp_timer_inactivity, null)
  twamp_server_port             = try(local.device_config[each.key].ip_sla.server_twamp_port, null)
  permanent_responders = length(concat(try(local.device_config[each.key].ip_sla.responder.udp_echos, []), try(local.device_config[each.key].ip_sla.responder.tcp_connects, []))) > 0 ? merge(
    { for r in try(local.device_config[each.key].ip_sla.responder.udp_echos, []) : "udp;${r.port};${try(r.ipaddress, "0.0.0.0")}" => {} },
    { for r in try(local.device_config[each.key].ip_sla.responder.tcp_connects, []) : "tcp;${r.port};${try(r.ipaddress, "0.0.0.0")}" => {} },
  ) : null
  probes = length(try(local.device_config[each.key].ip_sla.operations, [])) > 0 ? { for op in try(local.device_config[each.key].ip_sla.operations, []) : op.id => {
    icmp_echo_destination_ip                     = try(op.icmp_echo.destination, null) != null && (can(regex(":", try(op.icmp_echo.destination, ""))) || can(cidrnetmask("${try(op.icmp_echo.destination, "")}/32"))) ? try(op.icmp_echo.destination) : null
    icmp_echo_destination_hostname               = try(op.icmp_echo.destination, null) != null && !(can(regex(":", try(op.icmp_echo.destination, ""))) || can(cidrnetmask("${try(op.icmp_echo.destination, "")}/32"))) ? try(op.icmp_echo.destination) : null
    icmp_echo_source_ip                          = try(op.icmp_echo.source_ip, null) != null && (can(regex(":", try(op.icmp_echo.source_ip, ""))) || can(cidrnetmask("${try(op.icmp_echo.source_ip, "")}/32"))) ? try(op.icmp_echo.source_ip) : null
    icmp_echo_source_hostname                    = try(op.icmp_echo.source_ip, null) != null && !(can(regex(":", try(op.icmp_echo.source_ip, ""))) || can(cidrnetmask("${try(op.icmp_echo.source_ip, "")}/32"))) ? try(op.icmp_echo.source_ip) : null
    icmp_echo_source_interface                   = try(op.icmp_echo.source_interface_type, null) != null ? "${local.intf_prefix_map[try(op.icmp_echo.source_interface_type)]}${try(op.icmp_echo.source_interface_id, "")}" : null
    icmp_echo_request_data_size                  = try(op.icmp_echo.request_data_size, null)
    icmp_echo_verify_data                        = try(op.icmp_echo.verify_data, null)
    icmp_echo_tos                                = try(op.icmp_echo.tos, null)
    icmp_echo_ipv6_traffic_class                 = try(op.icmp_echo.traffic_class, null)
    icmp_echo_vrf                                = try(op.icmp_echo.vrf, null)
    icmp_echo_threshold                          = try(op.icmp_echo.threshold, null)
    icmp_echo_timeout                            = try(op.icmp_echo.timeout, null)
    icmp_echo_tag                                = try(op.icmp_echo.tag, null)
    icmp_echo_owner                              = try(op.icmp_echo.owner, null)
    icmp_echo_frequency                          = try(op.icmp_echo.frequency, null)
    icmp_echo_frequency_milliseconds             = try(op.icmp_echo.frequency_milliseconds, null)
    icmp_echo_buckets_kept                       = try(op.icmp_echo.history_buckets_kept, null)
    icmp_echo_distributions_of_statistics_kept   = try(op.icmp_echo.history_distributions_of_statistics_kept, null)
    icmp_echo_enhanced_buckets                   = try(op.icmp_echo.history_enhanced_buckets, null)
    icmp_echo_enhanced_interval                  = try(op.icmp_echo.history_enhanced_interval, null)
    icmp_echo_filter                             = try(local.sla_history_filter_map[try(op.icmp_echo.history_filter)], null)
    icmp_echo_hours_of_statistics_kept           = try(op.icmp_echo.history_hours_of_statistics_kept, null)
    icmp_echo_lives_kept                         = try(op.icmp_echo.history_lives_kept, null)
    icmp_echo_statistics_distribution_interval   = try(op.icmp_echo.history_statistics_distribution_interval, null)
    udp_echo_destination_ip                      = try(op.udp_echo.destination, null) != null && (can(regex(":", try(op.udp_echo.destination, ""))) || can(cidrnetmask("${try(op.udp_echo.destination, "")}/32"))) ? try(op.udp_echo.destination) : null
    udp_echo_destination_hostname                = try(op.udp_echo.destination, null) != null && !(can(regex(":", try(op.udp_echo.destination, ""))) || can(cidrnetmask("${try(op.udp_echo.destination, "")}/32"))) ? try(op.udp_echo.destination) : null
    udp_echo_destination_port                    = try(op.udp_echo.destination_port, null)
    udp_echo_control                             = try(op.udp_echo.control, null)
    udp_echo_source_ip                           = try(op.udp_echo.source_ip, null) != null && (can(regex(":", try(op.udp_echo.source_ip, ""))) || can(cidrnetmask("${try(op.udp_echo.source_ip, "")}/32"))) ? try(op.udp_echo.source_ip) : null
    udp_echo_source_hostname                     = try(op.udp_echo.source_ip, null) != null && !(can(regex(":", try(op.udp_echo.source_ip, ""))) || can(cidrnetmask("${try(op.udp_echo.source_ip, "")}/32"))) ? try(op.udp_echo.source_ip) : null
    udp_echo_source_port                         = try(op.udp_echo.source_port, null)
    udp_echo_request_data_size                   = try(op.udp_echo.request_data_size, null)
    udp_echo_verify_data                         = try(op.udp_echo.verify_data, null)
    udp_echo_data_pattern                        = try(op.udp_echo.data_pattern, null)
    udp_echo_tos                                 = try(op.udp_echo.tos, null)
    udp_echo_ipv6_traffic_class                  = try(op.udp_echo.traffic_class, null)
    udp_echo_vrf                                 = try(op.udp_echo.vrf, null)
    udp_echo_threshold                           = try(op.udp_echo.threshold, null)
    udp_echo_timeout                             = try(op.udp_echo.timeout, null)
    udp_echo_tag                                 = try(op.udp_echo.tag, null)
    udp_echo_owner                               = try(op.udp_echo.owner, null)
    udp_echo_frequency                           = try(op.udp_echo.frequency, null)
    udp_echo_frequency_milliseconds              = try(op.udp_echo.frequency_milliseconds, null)
    udp_echo_buckets_kept                        = try(op.udp_echo.history_buckets_kept, null)
    udp_echo_distributions_of_statistics_kept    = try(op.udp_echo.history_distributions_of_statistics_kept, null)
    udp_echo_enhanced_buckets                    = try(op.udp_echo.history_enhanced_buckets, null)
    udp_echo_enhanced_interval                   = try(op.udp_echo.history_enhanced_interval, null)
    udp_echo_filter                              = try(local.sla_history_filter_map[try(op.udp_echo.history_filter)], null)
    udp_echo_hours_of_statistics_kept            = try(op.udp_echo.history_hours_of_statistics_kept, null)
    udp_echo_lives_kept                          = try(op.udp_echo.history_lives_kept, null)
    udp_echo_statistics_distribution_interval    = try(op.udp_echo.history_statistics_distribution_interval, null)
    udp_jitter_destination_ip                    = try(op.udp_jitter.destination, null) != null && (can(regex(":", try(op.udp_jitter.destination, ""))) || can(cidrnetmask("${try(op.udp_jitter.destination, "")}/32"))) ? try(op.udp_jitter.destination) : null
    udp_jitter_destination_hostname              = try(op.udp_jitter.destination, null) != null && !(can(regex(":", try(op.udp_jitter.destination, ""))) || can(cidrnetmask("${try(op.udp_jitter.destination, "")}/32"))) ? try(op.udp_jitter.destination) : null
    udp_jitter_destination_port                  = try(op.udp_jitter.destination_port, null)
    udp_jitter_codec_type                        = try(op.udp_jitter.codec, null)
    udp_jitter_advantage_factor                  = try(op.udp_jitter.advantage_factor, null)
    udp_jitter_codec_interval                    = try(op.udp_jitter.codec_interval, null)
    udp_jitter_codec_number_of_packets           = try(op.udp_jitter.codec_numpackets, null)
    udp_jitter_codec_size                        = try(op.udp_jitter.codec_size, null)
    udp_jitter_interval                          = try(op.udp_jitter.interval, null)
    udp_jitter_number_of_packets                 = try(op.udp_jitter.num_packets, null)
    udp_jitter_control                           = try(op.udp_jitter.control, null)
    udp_jitter_source_ip                         = try(op.udp_jitter.source_ip, null) != null && (can(regex(":", try(op.udp_jitter.source_ip, ""))) || can(cidrnetmask("${try(op.udp_jitter.source_ip, "")}/32"))) ? try(op.udp_jitter.source_ip) : null
    udp_jitter_source_hostname                   = try(op.udp_jitter.source_ip, null) != null && !(can(regex(":", try(op.udp_jitter.source_ip, ""))) || can(cidrnetmask("${try(op.udp_jitter.source_ip, "")}/32"))) ? try(op.udp_jitter.source_ip) : null
    udp_jitter_source_port                       = try(op.udp_jitter.source_port, null)
    udp_jitter_request_data_size                 = try(op.udp_jitter.request_data_size, null)
    udp_jitter_verify_data                       = try(op.udp_jitter.verify_data, null)
    udp_jitter_tos                               = try(op.udp_jitter.tos, null)
    udp_jitter_ipv6_traffic_class                = try(op.udp_jitter.traffic_class, null)
    udp_jitter_vrf                               = try(op.udp_jitter.vrf, null)
    udp_jitter_threshold                         = try(op.udp_jitter.threshold, null)
    udp_jitter_timeout                           = try(op.udp_jitter.timeout, null)
    udp_jitter_tag                               = try(op.udp_jitter.tag, null)
    udp_jitter_owner                             = try(op.udp_jitter.owner, null)
    udp_jitter_frequency                         = try(op.udp_jitter.frequency, null)
    udp_jitter_operation_packet_priority         = try(op.udp_jitter.operation_packet_priority, null)
    udp_jitter_precision                         = try(op.udp_jitter.precision, null)
    udp_jitter_absolute_clock_tolerance          = try(op.udp_jitter.clock_tolerance_ntp_oneway_absolute, null)
    udp_jitter_percent_clock_tolerance           = try(op.udp_jitter.clock_tolerance_ntp_oneway_percent, null)
    udp_jitter_distributions_of_statistics_kept  = try(op.udp_jitter.history_distributions_of_statistics_kept, null)
    udp_jitter_hours_of_statistics_kept          = try(op.udp_jitter.history_hours_of_statistics_kept, null)
    udp_jitter_statistics_distribution_interval  = try(op.udp_jitter.history_statistics_distribution_interval, null)
    tcp_connect_destination_ip                   = try(op.tcp_connect.destination, null) != null && (can(regex(":", try(op.tcp_connect.destination, ""))) || can(cidrnetmask("${try(op.tcp_connect.destination, "")}/32"))) ? try(op.tcp_connect.destination) : null
    tcp_connect_destination_hostname             = try(op.tcp_connect.destination, null) != null && !(can(regex(":", try(op.tcp_connect.destination, ""))) || can(cidrnetmask("${try(op.tcp_connect.destination, "")}/32"))) ? try(op.tcp_connect.destination) : null
    tcp_connect_destination_port                 = try(op.tcp_connect.destination_port, null)
    tcp_connect_control                          = try(op.tcp_connect.control, null)
    tcp_connect_source_ip                        = try(op.tcp_connect.source_ip, null) != null && (can(regex(":", try(op.tcp_connect.source_ip, ""))) || can(cidrnetmask("${try(op.tcp_connect.source_ip, "")}/32"))) ? try(op.tcp_connect.source_ip) : null
    tcp_connect_source_hostname                  = try(op.tcp_connect.source_ip, null) != null && !(can(regex(":", try(op.tcp_connect.source_ip, ""))) || can(cidrnetmask("${try(op.tcp_connect.source_ip, "")}/32"))) ? try(op.tcp_connect.source_ip) : null
    tcp_connect_source_port                      = try(op.tcp_connect.source_port, null)
    tcp_connect_close_connection                 = try(op.tcp_connect.close_connection_fin, null)
    tcp_connect_tos                              = try(op.tcp_connect.tos, null)
    tcp_connect_ipv6_traffic_class               = try(op.tcp_connect.traffic_class, null)
    tcp_connect_vrf                              = try(op.tcp_connect.vrf, null)
    tcp_connect_threshold                        = try(op.tcp_connect.threshold, null)
    tcp_connect_timeout                          = try(op.tcp_connect.timeout, null)
    tcp_connect_tag                              = try(op.tcp_connect.tag, null)
    tcp_connect_owner                            = try(op.tcp_connect.owner, null)
    tcp_connect_frequency                        = try(op.tcp_connect.frequency, null)
    tcp_connect_frequency_milliseconds           = try(op.tcp_connect.frequency_milliseconds, null)
    tcp_connect_buckets_kept                     = try(op.tcp_connect.history_buckets_kept, null)
    tcp_connect_distributions_of_statistics_kept = try(op.tcp_connect.history_distributions_of_statistics_kept, null)
    tcp_connect_enhanced_buckets                 = try(op.tcp_connect.history_enhanced_buckets, null)
    tcp_connect_enhanced_interval                = try(op.tcp_connect.history_enhanced_interval, null)
    tcp_connect_filter                           = try(local.sla_history_filter_map[try(op.tcp_connect.history_filter)], null)
    tcp_connect_hours_of_statistics_kept         = try(op.tcp_connect.history_hours_of_statistics_kept, null)
    tcp_connect_lives_kept                       = try(op.tcp_connect.history_lives_kept, null)
    tcp_connect_statistics_distribution_interval = try(op.tcp_connect.history_statistics_distribution_interval, null)
    dns_target                                   = try(op.dns.target, null)
    dns_name_server_ip                           = try(op.dns.name_server, null) != null && (can(regex(":", try(op.dns.name_server, ""))) || can(cidrnetmask("${try(op.dns.name_server, "")}/32"))) ? try(op.dns.name_server) : null
    dns_name_server_hostname                     = try(op.dns.name_server, null) != null && !(can(regex(":", try(op.dns.name_server, ""))) || can(cidrnetmask("${try(op.dns.name_server, "")}/32"))) ? try(op.dns.name_server) : null
    dns_source_ip                                = try(op.dns.source_ip, null) != null && (can(regex(":", try(op.dns.source_ip, ""))) || can(cidrnetmask("${try(op.dns.source_ip, "")}/32"))) ? try(op.dns.source_ip) : null
    dns_source_hostname                          = try(op.dns.source_ip, null) != null && !(can(regex(":", try(op.dns.source_ip, ""))) || can(cidrnetmask("${try(op.dns.source_ip, "")}/32"))) ? try(op.dns.source_ip) : null
    dns_source_port                              = try(op.dns.source_port, null)
    dns_vrf                                      = try(op.dns.vrf, null)
    dns_threshold                                = try(op.dns.threshold, null)
    dns_timeout                                  = try(op.dns.timeout, null)
    dns_tag                                      = try(op.dns.tag, null)
    dns_owner                                    = try(op.dns.owner, null)
    dns_frequency                                = try(op.dns.frequency, null)
    dns_buckets_kept                             = try(op.dns.history_buckets_kept, null)
    dns_distributions_of_statistics_kept         = try(op.dns.history_distributions_of_statistics_kept, null)
    dns_filter                                   = try(local.sla_history_filter_map[try(op.dns.history_filter)], null)
    dns_hours_of_statistics_kept                 = try(op.dns.history_hours_of_statistics_kept, null)
    dns_lives_kept                               = try(op.dns.history_lives_kept, null)
    dns_statistics_distribution_interval         = try(op.dns.history_statistics_distribution_interval, null)
    http_url                                     = try(op.http.url, null)
    http_cache                                   = try(op.http.cache, null)
    http_proxy                                   = try(op.http.proxy, null)
    http_source_ip                               = try(op.http.source_ip, null) != null && (can(regex(":", try(op.http.source_ip, ""))) || can(cidrnetmask("${try(op.http.source_ip, "")}/32"))) ? try(op.http.source_ip) : null
    http_source_hostname                         = try(op.http.source_ip, null) != null && !(can(regex(":", try(op.http.source_ip, ""))) || can(cidrnetmask("${try(op.http.source_ip, "")}/32"))) ? try(op.http.source_ip) : null
    http_source_port                             = try(op.http.source_port, null)
    http_version                                 = try(op.http.version, null)
    http_tos                                     = try(op.http.tos, null)
    http_ipv6_traffic_class                      = try(op.http.traffic_class, null)
    http_vrf                                     = try(op.http.vrf, null)
    http_threshold                               = try(op.http.threshold, null)
    http_timeout                                 = try(op.http.timeout, null)
    http_tag                                     = try(op.http.tag, null)
    http_owner                                   = try(op.http.owner, null)
    http_frequency                               = try(op.http.frequency, null)
    http_buckets_kept                            = try(op.http.history_buckets_kept, null)
    http_distributions_of_statistics_kept        = try(op.http.history_distributions_of_statistics_kept, null)
    http_filter                                  = try(local.sla_history_filter_map[try(op.http.history_filter)], null)
    http_hours_of_statistics_kept                = try(op.http.history_hours_of_statistics_kept, null)
    http_lives_kept                              = try(op.http.history_lives_kept, null)
    http_statistics_distribution_interval        = try(op.http.history_statistics_distribution_interval, null)
    http_method                                  = try(op.http, null) != null ? "get" : null
    schedule_age_out                             = try(op.schedule.ageout, null)
    schedule_day_of_month                        = try(op.schedule.start_time_day, null)
    schedule_life                                = try(op.schedule.life_forever, false) ? 2147483647 : try(op.schedule.life, null)
    schedule_month                               = try(op.schedule.start_time_month, null)
    schedule_recurring                           = try(op.schedule.recurring, null)
    schedule_start_probe                         = try(op.schedule.start_time_now, false) ? "Now" : try(op.schedule.start_time_pending, false) ? "Pending" : try(op.schedule.start_time_after, null) != null ? "After" : try(op.schedule.start_time, null) != null ? "At" : null
    schedule_start_time                          = try(op.schedule.start_time_after, op.schedule.start_time, null)
    reactions = length(try(op.reaction_configurations, [])) > 0 ? { for r in try(op.reaction_configurations, []) : r.react => {
      lower_threshold   = try(r.threshold_value_lower, null)
      reaction_type     = try(r.action_type, null)
      threshold_count_x = try(r.threshold_type_x, null)
      threshold_count_y = try(r.threshold_type_y, null)
      threshold_type    = try(r.threshold_type, null)
      upper_threshold   = try(r.threshold_value_upper, null)
    } } : null
    reaction_triggers = length(try(op.reaction_triggers, [])) > 0 ? { for t in try(op.reaction_triggers, []) : t => {} } : null
  } } : null
  group_schedules = length(try(local.device_config[each.key].ip_sla.group_schedules, [])) > 0 ? { for gs in try(local.device_config[each.key].ip_sla.group_schedules, []) : gs.id => {
    age_out         = try(gs.ageout, null)
    day_of_month    = try(gs.start_time_day, null)
    frequency       = try(gs.frequency, null)
    frequency_range = try(gs.frequency_range, null)
    life            = try(gs.life_forever, false) ? 2147483647 : try(gs.life, null)
    month           = try(gs.start_time_month, null)
    probe_list      = try(gs.operation_ids, null)
    schedule_period = try(gs.schedule_period, null)
    start_probe     = try(gs.start_time_now, false) ? "Now" : try(gs.start_time_pending, false) ? "Pending" : try(gs.start_time_after, null) != null ? "After" : try(gs.start_time, null) != null ? "At" : null
    start_time      = try(gs.start_time_after, gs.start_time, null)
  } } : null

  depends_on = [
    nxos_cli.cli_pre_9,
    nxos_feature.feature,
    nxos_vrf.vrf,
    nxos_physical_interface.physical_interface,
    nxos_loopback_interface.loopback_interface,
    nxos_port_channel_interface.port_channel_interface,
    nxos_svi_interface.svi_interface,
  ]
}
