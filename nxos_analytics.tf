resource "nxos_analytics" "analytics" {
  for_each = { for device in local.devices : device.name => device
  if try(local.device_config[device.name].analytics, null) != null }
  device = each.key

  instances = {
    "analytics" = {
      admin_state              = try(local.device_config[each.key].analytics.shutdown, null) == null ? null : (try(local.device_config[each.key].analytics.shutdown) ? "disabled" : "enabled")
      collect_tunnel_header    = try(local.device_config[each.key].analytics.collect_tunnel_header, null)
      enable_analytics_submode = try(local.device_config[each.key].analytics.analytics_submode, null)
      geneve_enable            = try(local.device_config[each.key].analytics.geneve, null)
      timeout                  = try(local.device_config[each.key].analytics.flow_timeout, null)

      profiles = { for profile in try(local.device_config[each.key].analytics.flow_profiles, []) : profile.name => {
        burst_interval_shift                 = try(profile.burst_interval_shift, null)
        collect_interval                     = try(profile.collect_interval, null)
        ip_packet_id_shift                   = try(profile.ip_packet_id_shift, null)
        mtu                                  = try(profile.mtu, null)
        sequence_number_guess_threshold_high = try(profile.seq_num_guess_threshold_high, null)
        sequence_number_guess_threshold_low  = try(profile.seq_num_guess_threshold_low, null)
        source_port                          = try(profile.source_port, null)
      } }

      events = { for event in try(local.device_config[each.key].analytics.flow_events, []) : event.name => {
        acl_drops              = try(event.capture_acl_drops, null)
        black_hole             = try(event.capture_blackhole, null)
        buffer_drops           = try(event.capture_buffer_drops, null)
        event_export_max       = try(event.event_export_max, null)
        forward_drops          = try(event.capture_fwd_drops, null)
        group_drop_events      = try(event.group_drop_events, null)
        group_latency_events   = try(event.group_latency_events, null)
        group_packet_events    = try(event.group_packet_events, null)
        ip_dont_fragment       = try(event.capture_ip_df, null)
        latency_threshold      = try(event.latency_threshold, null)
        latency_threshold_unit = try(event.latency_threshold_unit, null)
        receive_window_zero    = try(event.capture_receive_window_zero, null)
        tos                    = try(event.capture_tos, null)
        tos_enable             = try(event.capture_tos, null) != null ? true : null
        ttl_match_enable       = try(event.capture_ttl, null) != null ? true : null
        ttl_match_value        = try(event.capture_ttl, null)
      } }

      policies = { for filter in try(local.device_config[each.key].analytics.flow_filters, []) : filter.name => {
        description = try(filter.description, null)

        match_acls = { for acl in try(filter.acls, []) : acl.name => {
          acl_name    = try(acl.acl_name, null)
          description = try(acl.description, null)
          filter_type = try(acl.filter_type, null)
        } }
      } }

      traffic_analytics_interface_mode               = try(local.device_config[each.key].analytics.flow_traffic_analytics.mode_interface, null)
      traffic_analytics_name                         = try(local.device_config[each.key].analytics.flow_traffic_analytics.name, null)
      traffic_analytics_service_database_size        = try(local.device_config[each.key].analytics.flow_traffic_analytics.db_size, null)
      traffic_analytics_troubleshoot_export_interval = try(local.device_config[each.key].analytics.flow_traffic_analytics.filter_export_interval, null)
      traffic_analytics_udp_port_list                = try(local.device_config[each.key].analytics.flow_traffic_analytics.udp_port, null)
    }
  }

  depends_on = [
    nxos_feature.feature,
  ]
}
