locals {
  eem_hard_error_map = {
    "0" = "soft_error"
    "1" = "hard_error"
    "2" = "soft_error_resettable"
    "3" = "soft_error_reset_replay_all_cfg"
    "4" = "soft_error_diag_failure"
  }
}

resource "nxos_eem" "eem" {
  for_each = { for device in local.devices : device.name => device
    if length(try(local.device_config[device.name].event_manager.environments, [])) > 0 ||
  length(try(local.device_config[device.name].event_manager.applets, [])) > 0 }
  device = each.key
  environment_variables = length(try(local.device_config[each.key].event_manager.environments, [])) > 0 ? { for env in try(local.device_config[each.key].event_manager.environments, []) : env.name => {
    value = try(env.value, null)
  } } : null
  applets = length(try(local.device_config[each.key].event_manager.applets, [])) > 0 ? { for applet in try(local.device_config[each.key].event_manager.applets, []) : applet.name => {
    description = try(applet.description, null)
    override    = try(applet.override, null)

    # event application sub-system <id> type <type>
    application_event_subsystem_id = try(applet.event.application.sub_system, null)
    application_event_type         = try(applet.event.application.type, null)
    # event neighbor-discovery interface <intf> cdp <op>
    cdp_event_interface = try(applet.event.neighbor_discovery.interface_type, null) != null ? "${local.intf_prefix_map[try(applet.event.neighbor_discovery.interface_type)]}${try(applet.event.neighbor_discovery.interface_id, "")}" : null
    cdp_event_operation = try(applet.event.neighbor_discovery.cdp, null)
    # event cli match <regex> count <n> time <t>
    cli_event_match         = try(applet.event.cli.match, null)
    cli_event_occurrences   = try(applet.event.cli.count, null)
    cli_event_time_interval = try(applet.event.cli.time, null)
    # event counter name <name> entry-val <val> entry-op <op> exit-val <val> exit-op <op>
    counter_event_name           = try(applet.event.counter.name, null)
    counter_event_entry_operator = try(applet.event.counter.entry_op, null)
    counter_event_entry_value    = try(applet.event.counter.entry_val, null)
    counter_event_exit_operator  = try(applet.event.counter.exit_op, null)
    counter_event_exit_value     = try(applet.event.counter.exit_val, null)
    # event storm-control
    ethpm_event_storm_control = try(applet.event.storm_control, null)
    # event fanabsent / fanbad fan <fan> time <t>
    fan_absent_event_fan  = try(tostring(applet.event.fanabsent.fan), null)
    fan_absent_event_time = try(applet.event.fanabsent.time, null)
    fan_bad_event_fan     = try(tostring(applet.event.fanbad.fan), null)
    fan_bad_event_time    = try(applet.event.fanbad.time, null)
    # event gold module {<module> | all} test <name> severity <sev> testing-type <type> consecutive-failure <n>
    gold_event_module               = try(applet.event.gold.module, null) == null || try(applet.event.gold.module, null) == "all" ? null : try(applet.event.gold.module)
    gold_event_module_all           = try(applet.event.gold.module, null) == "all" ? "enabled" : null
    gold_event_test_name            = try(applet.event.gold.test, null)
    gold_event_testing_type         = try(applet.event.gold.testing_type, null)
    gold_event_severity             = try(applet.event.gold.severity, null)
    gold_event_consecutive_failures = try(applet.event.gold.consecutive_failure, null)
    # event internal-link-flap count <n> time <t>
    internal_link_flap_event_count = try(applet.event.internal_link_flap.count, null)
    internal_link_flap_event_time  = try(applet.event.internal_link_flap.time, null)
    # event memory {minor | severe | critical}
    memory_event_level = try(applet.event.memory, null)
    # event module status <status> module <module>
    module_event_module = try(tostring(applet.event.module.module), null)
    module_event_status = try(applet.event.module.status, null)
    # event module-failure type <type> module <module> count <n> time <t>
    module_failure_event_module     = try(tostring(applet.event.module_failure.module), null)
    module_failure_event_error_type = try(applet.event.module_failure.type, null)
    module_failure_event_count      = try(applet.event.module_failure.count, null)
    module_failure_event_time       = try(applet.event.module_failure.time, null)
    # event none
    none_event = try(applet.event.none, null)
    # event oir {fan | module | powersupply} {insert | remove | anyoir} <number>
    oir_event_device_type   = try(applet.event.oir.fan, null) != null ? "fan" : try(applet.event.oir.module, null) != null ? "module" : try(applet.event.oir.powersupply, null) != null ? "powersupply" : null
    oir_event_type          = try(applet.event.oir.fan, applet.event.oir.module, applet.event.oir.powersupply, null)
    oir_event_device_number = try(applet.event.oir.number, null)
    # event policy-default {disable | count <n> time <t>}
    policy_default_event_disable       = try(applet.event.policy_default.disable, null)
    policy_default_event_occurrences   = try(applet.event.policy_default.count, null)
    policy_default_event_time_interval = try(applet.event.policy_default.time, null)
    # event poweroverbudget
    power_over_budget_event = try(applet.event.poweroverbudget, null)
    # event snmp oid <oid> get-type <type> entry-op <op> entry-val <val> [exit-comb <comb> exit-op <op> exit-val <val> exit-time <t> | exit-op <op> exit-val <val>] poll-interval <t>
    snmp_event_oid                   = try(applet.event.snmp.oid, null)
    snmp_event_get_type              = try(applet.event.snmp.get_type, null)
    snmp_event_entry_operator        = try(applet.event.snmp.entry_op, null)
    snmp_event_entry_value           = try(applet.event.snmp.entry_val, null)
    snmp_event_exit_combination      = try(applet.event.snmp.exit_comb, null)
    snmp_event_exit_operator         = try(applet.event.snmp.exit_comb, null) != null ? try(applet.event.snmp.exit_op, null) : null
    snmp_event_exit_value            = try(applet.event.snmp.exit_comb, null) != null ? try(applet.event.snmp.exit_val, null) : null
    snmp_event_exit_operator_1       = try(applet.event.snmp.exit_comb, null) == null ? try(applet.event.snmp.exit_op, null) : null
    snmp_event_exit_value_1          = try(applet.event.snmp.exit_comb, null) == null ? try(applet.event.snmp.exit_val, null) : null
    snmp_event_exit_time_minimum     = try(applet.event.snmp.exit_time, null)
    snmp_event_exit_time_maximum     = try(applet.event.snmp.exit_time, null)
    snmp_event_poll_interval_minimum = try(applet.event.snmp.poll_interval, null)
    snmp_event_poll_interval_maximum = try(applet.event.snmp.poll_interval, null)
    # event syslog occurs <n> period <t> priority <prio> pattern <regex>
    syslog_event_pattern       = try(applet.event.syslog.pattern, null)
    syslog_event_priority      = try(tostring(applet.event.syslog.priority), null)
    syslog_event_occurrences   = try(applet.event.syslog.occurs, null)
    syslog_event_time_interval = try(applet.event.syslog.period, null)
    # event sysmgr memory module <module> major <n> minor <n> clear <n>
    sysmgr_memory_alert_event_module = try(applet.event.sysmgr_memory.module, null)
    sysmgr_memory_alert_event_minor  = try(applet.event.sysmgr_memory.minor, null)
    sysmgr_memory_alert_event_major  = try(applet.event.sysmgr_memory.major, null)
    sysmgr_memory_alert_event_clear  = try(applet.event.sysmgr_memory.clear, null)
    # event sysmgr switchover count <n> time <t>
    sysmgr_switchover_event_count = try(applet.event.sysmgr_switchover.count, null)
    sysmgr_switchover_event_time  = try(applet.event.sysmgr_switchover.time, null)
    # event temperature module <module> sensor <sensor> threshold <level>
    temperature_event_module    = try(tostring(applet.event.temperature.module), null)
    temperature_event_sensor    = try(tostring(applet.event.temperature.sensor), null)
    temperature_event_threshold = try(applet.event.temperature.threshold, null)
    # event timer {watchdog | absolute | countdown} time <t> | cron cron-entry <entry>; name <name>
    timer_event_name           = try(applet.event.timer.name, null)
    timer_event_absolute_time  = try(tostring(applet.event.timer.absolute_time), null)
    timer_event_countdown_time = try(tostring(applet.event.timer.countdown_time), null)
    timer_event_cron_time      = try(applet.event.timer.cron_entry, null)
    timer_event_watchdog_time  = try(tostring(applet.event.timer.watchdog_time), null)
    # event track <id> state <state>
    track_event_id    = try(applet.event.track.id, null)
    track_event_state = try(applet.event.track.state, null)
    # event fib route <type> | fib resource tcam usage | fib adjacency extra
    ufdm_event_fib = try(applet.event.fib_route, null) != null ? try(applet.event.fib_route) : try(applet.event.fib_resource_tcam_usage, false) ? "tcam-resource" : try(applet.event.fib_adjacency_extra, false) ? "adjacency" : null

    # tag <tag> <op> <tag> ... happens <n> in <t>
    correlation_tag_1         = try(applet.tag.tag_1, null)
    correlation_operator_1    = try(applet.tag.operator_1, null)
    correlation_tag_2         = try(applet.tag.tag_2, null)
    correlation_operator_2    = try(applet.tag.operator_2, null)
    correlation_tag_3         = try(applet.tag.tag_3, null)
    correlation_operator_3    = try(applet.tag.operator_3, null)
    correlation_tag_4         = try(applet.tag.tag_4, null)
    correlation_occurrences   = try(applet.tag.happens, null)
    correlation_time_interval = try(applet.tag.in, null)

    # Tagged events: event <type> tag <tag> ...
    application_events = length([for t in try(applet.event.tags, []) : t if try(t.application, null) != null]) > 0 ? { for t in try(applet.event.tags, []) : t.tag => {
      subsystem_id = try(t.application.sub_system, null)
      type         = try(t.application.type, null)
    } if try(t.application, null) != null } : null
    cdp_events = length([for t in try(applet.event.tags, []) : t if try(t.neighbor_discovery, null) != null]) > 0 ? { for t in try(applet.event.tags, []) : t.tag => {
      interface = try(t.neighbor_discovery.interface_type, null) != null ? "${local.intf_prefix_map[try(t.neighbor_discovery.interface_type)]}${try(t.neighbor_discovery.interface_id, "")}" : null
      operation = try(t.neighbor_discovery.cdp, null)
    } if try(t.neighbor_discovery, null) != null } : null
    cli_events = length([for t in try(applet.event.tags, []) : t if try(t.cli, null) != null]) > 0 ? { for t in try(applet.event.tags, []) : t.tag => {
      match = try(t.cli.match, null)
    } if try(t.cli, null) != null } : null
    counter_events = length([for t in try(applet.event.tags, []) : t if try(t.counter, null) != null]) > 0 ? { for t in try(applet.event.tags, []) : t.tag => {
      name           = try(t.counter.name, null)
      entry_operator = try(t.counter.entry_op, null)
      entry_value    = try(t.counter.entry_val, null)
      exit_operator  = try(t.counter.exit_op, null)
      exit_value     = try(t.counter.exit_val, null)
    } if try(t.counter, null) != null } : null
    module_events = length([for t in try(applet.event.tags, []) : t if try(t.module, null) != null]) > 0 ? { for t in try(applet.event.tags, []) : t.tag => {
      module = try(tostring(t.module.module), null)
      status = try(t.module.status, null)
    } if try(t.module, null) != null } : null
    none_events = length([for t in try(applet.event.tags, []) : t if try(t.none, false) == true]) > 0 ? { for t in try(applet.event.tags, []) : t.tag => {
      enabled = true
    } if try(t.none, false) == true } : null
    oir_events = length([for t in try(applet.event.tags, []) : t if try(t.oir, null) != null]) > 0 ? { for t in try(applet.event.tags, []) : t.tag => {
      device_type   = try(t.oir.fan, null) != null ? "fan" : try(t.oir.module, null) != null ? "module" : try(t.oir.powersupply, null) != null ? "powersupply" : null
      type          = try(t.oir.fan, t.oir.module, t.oir.powersupply, null)
      device_number = try(t.oir.number, null)
    } if try(t.oir, null) != null } : null
    snmp_events = length([for t in try(applet.event.tags, []) : t if try(t.snmp, null) != null]) > 0 ? { for t in try(applet.event.tags, []) : t.tag => {
      oid                   = try(t.snmp.oid, null)
      get_type              = try(t.snmp.get_type, null)
      entry_operator        = try(t.snmp.entry_op, null)
      entry_value           = try(t.snmp.entry_val, null)
      exit_combination      = try(t.snmp.exit_comb, null)
      exit_operator         = try(t.snmp.exit_comb, null) != null ? try(t.snmp.exit_op, null) : null
      exit_value            = try(t.snmp.exit_comb, null) != null ? try(t.snmp.exit_val, null) : null
      exit_operator_1       = try(t.snmp.exit_comb, null) == null ? try(t.snmp.exit_op, null) : null
      exit_value_1          = try(t.snmp.exit_comb, null) == null ? try(t.snmp.exit_val, null) : null
      exit_time_minimum     = try(t.snmp.exit_time, null)
      exit_time_maximum     = try(t.snmp.exit_time, null)
      poll_interval_minimum = try(t.snmp.poll_interval, null)
      poll_interval_maximum = try(t.snmp.poll_interval, null)
    } if try(t.snmp, null) != null } : null
    syslog_events = length([for t in try(applet.event.tags, []) : t if try(t.syslog, null) != null]) > 0 ? { for t in try(applet.event.tags, []) : t.tag => {
      pattern  = try(t.syslog.pattern, null)
      priority = try(tostring(t.syslog.priority), null)
    } if try(t.syslog, null) != null } : null
    timer_events = length([for t in try(applet.event.tags, []) : t if try(t.timer, null) != null]) > 0 ? { for t in try(applet.event.tags, []) : t.tag => {
      name           = try(t.timer.name, null)
      absolute_time  = try(tostring(t.timer.absolute_time), null)
      countdown_time = try(tostring(t.timer.countdown_time), null)
      cron_time      = try(t.timer.cron_entry, null)
      watchdog_time  = try(tostring(t.timer.watchdog_time), null)
    } if try(t.timer, null) != null } : null
    track_events = length([for t in try(applet.event.tags, []) : t if try(t.track, null) != null]) > 0 ? { for t in try(applet.event.tags, []) : t.tag => {
      id    = try(t.track.id, null)
      state = try(t.track.state, null)
    } if try(t.track, null) != null } : null

    # action <label> ...
    actions = length(try(applet.actions, [])) > 0 ? { for action in try(applet.actions, []) : tostring(action.label) => {
      cli_command                 = try(action.cli, null)
      cli_local                   = try(action.cli_local, null)
      collect_yaml_file           = try(action.collect_yaml_file, null)
      collect_component           = try(action.collect_component, null)
      collect_rate_limit          = try(action.collect_rate_limit, null)
      collect_max_triggers        = try(action.collect_max_triggers, null)
      collect_purge_time          = try(action.collect_purge_time, null)
      collect_status              = try(action.collect_disable, null) == null ? null : (try(action.collect_disable) ? "disabled" : "enabled")
      counter_name                = try(action.counter_name, null)
      counter_operation           = try(action.counter_op, null)
      counter_value               = try(tostring(action.counter_value), null)
      event_default               = try(action.event_default, null)
      exception_log_module        = try(tostring(action.exceptionlog_module), null)
      exception_log_syserr        = try(action.exceptionlog_syserr, null)
      exception_log_device_id     = try(tostring(action.exceptionlog_devid), null)
      exception_log_error_type    = try(tostring(action.exceptionlog_errtype), null)
      exception_log_error_code    = try(tostring(action.exceptionlog_errcode), null)
      exception_log_phy_layer     = try(tostring(action.exceptionlog_phylayer), null)
      exception_log_ports         = try(tostring(action.exceptionlog_ports), null)
      exception_log_hard_error    = try(local.eem_hard_error_map[tostring(action.exceptionlog_harderror)], null)
      exception_log_description   = try(action.exceptionlog_desc, null) == null ? null : can(regex("^\".*\"$", action.exceptionlog_desc)) ? action.exceptionlog_desc : "\"${action.exceptionlog_desc}\""
      force_shutdown_module       = try(tostring(action.forceshut_module), null)
      force_shutdown_reset_reason = try(action.forceshut_reset_reason, null) == null ? null : can(regex("^\".*\"$", action.forceshut_reset_reason)) ? action.forceshut_reset_reason : "\"${action.forceshut_reset_reason}\""
      overbudget_shutdown_module  = try(action.overbudgetshut, false) ? try(tostring(action.overbudgetshut_module), "all") : null
      policy_default              = try(action.policy_default, null)
      publish_event_subsystem_id  = try(action.publish_event_sub_system, null)
      publish_event_type          = try(action.publish_event_type, null)
      publish_event_argument_1    = try(action.publish_event_arg1, null)
      publish_event_argument_2    = try(action.publish_event_arg2, null)
      publish_event_argument_3    = try(action.publish_event_arg3, null)
      publish_event_argument_4    = try(action.publish_event_arg4, null)
      reload_module               = try(action.reload, false) ? try(tostring(action.reload_module), "all") : null
      snmp_trap                   = try(action.snmp_trap, null)
      snmp_trap_integer_data_1    = try(tostring(action.snmp_trap_intdata1), null)
      snmp_trap_integer_data_2    = try(tostring(action.snmp_trap_intdata2), null)
      snmp_trap_string_data       = try(action.snmp_trap_strdata, null)
      syslog_priority             = try(action.syslog_priority, null)
      syslog_message              = try(action.syslog_msg, null)
    } } : null
  } } : null

  depends_on = [
    nxos_cli.cli_pre_9,
    nxos_feature.feature,
    nxos_track.track,
  ]
}
