locals {
  vpc_domains = flatten([
    for device in local.devices : [
      try(local.device_config[device.name].vpc_domain, null) != null ? {
        key                            = format("%s/%s", device.name, local.device_config[device.name].vpc_domain.domain_id)
        device                         = device.name
        domain_id                      = try(local.device_config[device.name].vpc_domain.domain_id, local.defaults.nxos.devices.configuration.vpc_domains.domain_id, null)
        admin_state                    = try(local.device_config[device.name].vpc_domain.admin_state, local.defaults.nxos.devices.configuration.vpc_domains.admin_state, true)
        auto_recovery                  = try(local.device_config[device.name].vpc_domain.auto_recovery, local.defaults.nxos.devices.configuration.vpc_domains.auto_recovery, false)
        auto_recovery_interval         = try(local.device_config[device.name].vpc_domain.auto_recovery_interval, local.defaults.nxos.devices.configuration.vpc_domains.auto_recovery_interval, null)
        delay_restore_orphan_port      = try(local.device_config[device.name].vpc_domain.delay_restore_orphan_port, local.defaults.nxos.devices.configuration.vpc_domains.delay_restore_orphan_port, null)
        delay_restore_svi              = try(local.device_config[device.name].vpc_domain.delay_restore_svi, local.defaults.nxos.devices.configuration.vpc_domains.delay_restore_svi, null)
        delay_restore_vpc              = try(local.device_config[device.name].vpc_domain.delay_restore_vpc, local.defaults.nxos.devices.configuration.vpc_domains.delay_restore_vpc, null)
        dscp                           = try(local.device_config[device.name].vpc_domain.dscp, local.defaults.nxos.devices.configuration.vpc_domains.dscp, null)
        fast_convergence               = try(local.device_config[device.name].vpc_domain.fast_convergence, local.defaults.nxos.devices.configuration.vpc_domains.fast_convergence, false)
        graceful_consistency_check     = try(local.device_config[device.name].vpc_domain.graceful_consistency_check, local.defaults.nxos.devices.configuration.vpc_domains.graceful_consistency_check, false)
        l3_peer_router                 = try(local.device_config[device.name].vpc_domain.l3_peer_router, local.defaults.nxos.devices.configuration.vpc_domains.l3_peer_router, null)
        l3_peer_router_syslog          = try(local.device_config[device.name].vpc_domain.l3_peer_router_syslog, local.defaults.nxos.devices.configuration.vpc_domains.l3_peer_router_syslog, false)
        l3_peer_router_syslog_interval = try(local.device_config[device.name].vpc_domain.l3_peer_router_syslog_interval, local.defaults.nxos.devices.configuration.vpc_domains.l3_peer_router_syslog_interval, null)
        peer_gateway                   = try(local.device_config[device.name].vpc_domain.peer_gateway, local.defaults.nxos.devices.configuration.vpc_domains.peer_gateway, false)
        peer_ip                        = try(local.device_config[device.name].vpc_domain.peer_ip, local.defaults.nxos.devices.configuration.vpc_domains.peer_ip, null)
        peer_switch                    = try(local.device_config[device.name].vpc_domain.peer_switch, local.defaults.nxos.devices.configuration.vpc_domains.peer_switch, false)
        role_priority                  = try(local.device_config[device.name].vpc_domain.role_priority, local.defaults.nxos.devices.configuration.vpc_domains.role_priority, null)
        system_mac                     = try(upper(local.device_config[device.name].vpc_domain.system_mac), upper(local.defaults.nxos.devices.configuration.vpc_domains.system_mac), null)
        system_priority                = try(local.device_config[device.name].vpc_domain.system_priority, local.defaults.nxos.devices.configuration.vpc_domains.system_priority, null)
        track                          = try(local.device_config[device.name].vpc_domain.track, local.defaults.nxos.devices.configuration.vpc_domains.track, null)
        virtual_ip                     = try(local.device_config[device.name].vpc_domain.virtual_ip, local.defaults.nxos.devices.configuration.vpc_domains.virtual_ip, null)
        peer_keepalive                 = try(local.device_config[device.name].vpc_domain.peer_keepalive, {})
      } : null
    ] if try(local.device_config[device.name].vpc_domain, null) != null
  ])
}

resource "nxos_vpc_instance" "vpc_instance" {
  for_each    = { for vpc_domain in local.vpc_domains : vpc_domain.key => vpc_domain }
  device      = each.value.device
  admin_state = try(each.value.admin_state, local.defaults.nxos.devices.configuration.vpc_domains.admin_state, true) ? "enabled" : "disabled"

  depends_on = [
    nxos_feature_vpc.vpc
  ]
}

resource "nxos_vpc_domain" "vpc_domain" {
  for_each                       = { for vpc_domain in local.vpc_domains : vpc_domain.key => vpc_domain }
  device                         = each.value.device
  domain_id                      = each.value.domain_id
  admin_state                    = try(each.value.admin_state, local.defaults.nxos.devices.configuration.vpc_domains.admin_state, true) ? "enabled" : "disabled"
  auto_recovery                  = try(each.value.auto_recovery, local.defaults.nxos.devices.configuration.vpc_domains.auto_recovery, false) ? "enabled" : "disabled"
  auto_recovery_interval         = try(each.value.auto_recovery_interval, local.defaults.nxos.devices.configuration.vpc_domains.auto_recovery_interval, null)
  delay_restore_orphan_port      = try(each.value.delay_restore_orphan_port, local.defaults.nxos.devices.configuration.vpc_domains.delay_restore_orphan_port, null)
  delay_restore_svi              = try(each.value.delay_restore_svi, local.defaults.nxos.devices.configuration.vpc_domains.delay_restore_svi, null)
  delay_restore_vpc              = try(each.value.delay_restore_vpc, local.defaults.nxos.devices.configuration.vpc_domains.delay_restore_vpc, null)
  dscp                           = try(each.value.dscp, local.defaults.nxos.devices.configuration.vpc_domains.dscp, null)
  fast_convergence               = try(each.value.fast_convergence, local.defaults.nxos.devices.configuration.vpc_domains.fast_convergence, false) ? "enabled" : "disabled"
  graceful_consistency_check     = try(each.value.graceful_consistency_check, local.defaults.nxos.devices.configuration.vpc_domains.graceful_consistency_check, false) ? "enabled" : "disabled"
  l3_peer_router                 = try(each.value.l3_peer_router, local.defaults.nxos.devices.configuration.vpc_domains.l3_peer_router, false) ? "enabled" : "disabled"
  l3_peer_router_syslog          = try(each.value.l3_peer_router_syslog, local.defaults.nxos.devices.configuration.vpc_domains.l3_peer_router_syslog, false) ? "enabled" : "disabled"
  l3_peer_router_syslog_interval = try(each.value.l3_peer_router_syslog_interval, local.defaults.nxos.devices.configuration.vpc_domains.l3_peer_router_syslog_interval, null)
  peer_gateway                   = try(each.value.peer_gateway, local.defaults.nxos.devices.configuration.vpc_domains.peer_gateway, false) ? "enabled" : "disabled"
  peer_ip                        = try(each.value.peer_ip, local.defaults.nxos.devices.configuration.vpc_domains.peer_ip, null)
  peer_switch                    = try(each.value.peer_switch, local.defaults.nxos.devices.configuration.vpc_domains.peer_switch, false) ? "enabled" : "disabled"
  role_priority                  = try(each.value.role_priority, local.defaults.nxos.devices.configuration.vpc_domains.role_priority, null)
  sys_mac                        = try(each.value.system_mac, local.defaults.nxos.devices.configuration.vpc_domains.system_mac, null)
  system_priority                = try(each.value.system_priority, local.defaults.nxos.devices.configuration.vpc_domains.system_priority, null)
  track                          = try(each.value.track, local.defaults.nxos.devices.configuration.vpc_domains.track, null)
  virtual_ip                     = try(each.value.virtual_ip, local.defaults.nxos.devices.configuration.vpc_domains.virtual_ip, null)

  depends_on = [
    nxos_vpc_instance.vpc_instance
  ]
}

resource "nxos_vpc_keepalive" "vpc_keepalive" {
  for_each                           = { for vpc_domain in local.vpc_domains : vpc_domain.key => vpc_domain }
  device                             = each.value.device
  destination_ip                     = try(each.value.peer_keepalive.destination_ip, local.defaults.nxos.devices.configuration.vpc_domains.keepalives.destination_ip, null)
  source_ip                          = try(each.value.peer_keepalive.source_ip, local.defaults.nxos.devices.configuration.vpc_domains.keepalives.source_ip, null)
  flush_timeout                      = try(each.value.peer_keepalive.flush_timeout, local.defaults.nxos.devices.configuration.vpc_domains.keepalives.flush_timeout, null)
  interval                           = try(each.value.peer_keepalive.interval, local.defaults.nxos.devices.configuration.vpc_domains.keepalives.interval, null)
  precedence_type                    = try(each.value.peer_keepalive.precedence_type, local.defaults.nxos.devices.configuration.vpc_domains.keepalives.precedence_type, null)
  precedence_value                   = try(each.value.peer_keepalive.precedence_value, local.defaults.nxos.devices.configuration.vpc_domains.keepalives.precedence_value, null)
  timeout                            = try(each.value.peer_keepalive.timeout, local.defaults.nxos.devices.configuration.vpc_domains.keepalives.timeout, null)
  type_of_service_byte               = try(each.value.peer_keepalive.type_of_service_byte, local.defaults.nxos.devices.configuration.vpc_domains.keepalives.type_of_service_byte, null)
  type_of_service_configuration_type = try(each.value.peer_keepalive.type_of_service_configuration_type, local.defaults.nxos.devices.configuration.vpc_domains.keepalives.type_of_service_configuration_type, null)
  type_of_service_type               = try(each.value.peer_keepalive.type_of_service_type, local.defaults.nxos.devices.configuration.vpc_domains.keepalives.type_of_service_type, null)
  type_of_service_value              = try(each.value.peer_keepalive.type_of_service_value, local.defaults.nxos.devices.configuration.vpc_domains.keepalives.type_of_service_value, null)
  udp_port                           = try(each.value.peer_keepalive.udp_port, local.defaults.nxos.devices.configuration.vpc_domains.keepalives.udp_port, null)
  vrf                                = try(each.value.peer_keepalive.vrf, local.defaults.nxos.devices.configuration.vpc_domains.keepalives.vrf, null)

  depends_on = [
    nxos_vpc_domain.vpc_domain
  ]
}

locals {
  vpc_peerlinks = flatten([
    for device in local.devices : [
      for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        key             = format("%s/%s", device.name, int.id)
        device          = device.name
        port_channel_id = int.id
      } if try(int.vpc_peerlink, false) == true
    ]
  ])
}

resource "nxos_vpc_peerlink" "vpc_peerlink" {
  for_each        = { for peerlink in local.vpc_peerlinks : peerlink.key => peerlink }
  device          = each.value.device
  port_channel_id = format("po%s", each.value.port_channel_id)

  depends_on = [
    nxos_vpc_keepalive.vpc_keepalive
  ]
}

locals {
  vpc_interfaces_port_channels = flatten([
    for device in local.devices : [
      for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        key                       = format("%s/%s", device.name, int.id)
        device                    = device.name
        vpc_interface_id          = int.vpc_id
        port_channel_interface_dn = format("sys/intf/aggr-[po%s]", int.id)
      } if try(int.vpc_id, null) != null && try(int.vpc_peerlink, false) == false
    ]
  ])
}

resource "nxos_vpc_interface" "vpc_interface" {
  for_each                  = { for int in local.vpc_interfaces_port_channels : int.key => int }
  device                    = each.value.device
  vpc_interface_id          = each.value.vpc_interface_id
  port_channel_interface_dn = each.value.port_channel_interface_dn

  depends_on = [
    nxos_vpc_domain.vpc_domain,
    nxos_port_channel_interface.port_channel_interface
  ]
}
