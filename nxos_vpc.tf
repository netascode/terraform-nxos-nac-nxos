locals {
  vpc_domains = flatten([
    for device in local.devices : [
      try(local.device_config[device.name].vpc_domain, null) != null ? {
        key                             = format("%s/%s", device.name, local.device_config[device.name].vpc_domain.domain_id)
        device                          = device.name
        domain_id                       = try(local.device_config[device.name].vpc_domain.domain_id, local.defaults.nxos.devices.configuration.vpc_domains.domain_id, null)
        admin_state                     = try(local.device_config[device.name].vpc_domain.admin_state, local.defaults.nxos.devices.configuration.vpc_domains.admin_state, true)
        auto_recovery                   = try(local.device_config[device.name].vpc_domain.auto_recovery, local.defaults.nxos.devices.configuration.vpc_domains.auto_recovery, false)
        auto_recovery_interval          = try(local.device_config[device.name].vpc_domain.auto_recovery_interval, local.defaults.nxos.devices.configuration.vpc_domains.auto_recovery_interval, null)
        delay_restore_orphan_port       = try(local.device_config[device.name].vpc_domain.delay_restore_orphan_port, local.defaults.nxos.devices.configuration.vpc_domains.delay_restore_orphan_port, null)
        delay_restore_svi               = try(local.device_config[device.name].vpc_domain.delay_restore_svi, local.defaults.nxos.devices.configuration.vpc_domains.delay_restore_svi, null)
        delay_restore_vpc               = try(local.device_config[device.name].vpc_domain.delay_restore_vpc, local.defaults.nxos.devices.configuration.vpc_domains.delay_restore_vpc, null)
        dscp                            = try(local.device_config[device.name].vpc_domain.dscp, local.defaults.nxos.devices.configuration.vpc_domains.dscp, null)
        fast_convergence                = try(local.device_config[device.name].vpc_domain.fast_convergence, local.defaults.nxos.devices.configuration.vpc_domains.fast_convergence, false)
        graceful_consistency_check      = try(local.device_config[device.name].vpc_domain.graceful_consistency_check, local.defaults.nxos.devices.configuration.vpc_domains.graceful_consistency_check, false)
        l3_peer_router                  = try(local.device_config[device.name].vpc_domain.l3_peer_router, local.defaults.nxos.devices.configuration.vpc_domains.l3_peer_router, null)
        l3_peer_router_syslog           = try(local.device_config[device.name].vpc_domain.l3_peer_router_syslog, local.defaults.nxos.devices.configuration.vpc_domains.l3_peer_router_syslog, false)
        l3_peer_router_syslog_interval  = try(local.device_config[device.name].vpc_domain.l3_peer_router_syslog_interval, local.defaults.nxos.devices.configuration.vpc_domains.l3_peer_router_syslog_interval, null)
        peer_gateway                    = try(local.device_config[device.name].vpc_domain.peer_gateway, local.defaults.nxos.devices.configuration.vpc_domains.peer_gateway, false)
        virtual_peerlink_destination_ip = try(local.device_config[device.name].vpc_domain.virtual_peerlink_destination_ip, local.defaults.nxos.devices.configuration.vpc_domains.virtual_peerlink_destination_ip, null)
        peer_switch                     = try(local.device_config[device.name].vpc_domain.peer_switch, local.defaults.nxos.devices.configuration.vpc_domains.peer_switch, false)
        role_priority                   = try(local.device_config[device.name].vpc_domain.role_priority, local.defaults.nxos.devices.configuration.vpc_domains.role_priority, null)
        system_mac                      = try(upper(local.device_config[device.name].vpc_domain.system_mac), upper(local.defaults.nxos.devices.configuration.vpc_domains.system_mac), null)
        system_priority                 = try(local.device_config[device.name].vpc_domain.system_priority, local.defaults.nxos.devices.configuration.vpc_domains.system_priority, null)
        track                           = try(local.device_config[device.name].vpc_domain.track, local.defaults.nxos.devices.configuration.vpc_domains.track, null)
        virtual_peerlink_source_ip      = try(local.device_config[device.name].vpc_domain.virtual_peerlink_source_ip, local.defaults.nxos.devices.configuration.vpc_domains.virtual_peerlink_source_ip, null)
        peer_keepalive                  = try(local.device_config[device.name].vpc_domain.peer_keepalive, {})
      } : null
    ] if try(local.device_config[device.name].vpc_domain, null) != null
  ])
}

resource "nxos_vpc_instance" "vpc_instance" {
  for_each    = { for vpc_domain in local.vpc_domains : vpc_domain.key => vpc_domain }
  device      = each.value.device
  admin_state = each.value.admin_state ? "enabled" : "disabled"

  depends_on = [
    nxos_feature_vpc.vpc
  ]
}

resource "nxos_vpc_domain" "vpc_domain" {
  for_each                       = { for vpc_domain in local.vpc_domains : vpc_domain.key => vpc_domain }
  device                         = each.value.device
  domain_id                      = each.value.domain_id
  admin_state                    = each.value.admin_state ? "enabled" : "disabled"
  auto_recovery                  = each.value.auto_recovery ? "enabled" : "disabled"
  auto_recovery_interval         = each.value.auto_recovery_interval
  delay_restore_orphan_port      = each.value.delay_restore_orphan_port
  delay_restore_svi              = each.value.delay_restore_svi
  delay_restore_vpc              = each.value.delay_restore_vpc
  dscp                           = each.value.dscp
  fast_convergence               = each.value.fast_convergence ? "enabled" : "disabled"
  graceful_consistency_check     = each.value.graceful_consistency_check ? "enabled" : "disabled"
  l3_peer_router                 = each.value.l3_peer_router ? "enabled" : "disabled"
  l3_peer_router_syslog          = each.value.l3_peer_router_syslog ? "enabled" : "disabled"
  l3_peer_router_syslog_interval = each.value.l3_peer_router_syslog_interval
  peer_gateway                   = each.value.peer_gateway ? "enabled" : "disabled"
  peer_ip                        = each.value.virtual_peerlink_destination_ip
  peer_switch                    = each.value.peer_switch ? "enabled" : "disabled"
  role_priority                  = each.value.role_priority
  sys_mac                        = each.value.system_mac
  system_priority                = each.value.system_priority
  track                          = each.value.track
  virtual_ip                     = each.value.virtual_peerlink_source_ip

  depends_on = [
    nxos_vpc_instance.vpc_instance
  ]
}

resource "nxos_vpc_keepalive" "vpc_keepalive" {
  for_each                           = { for vpc_domain in local.vpc_domains : vpc_domain.key => vpc_domain }
  device                             = each.value.device
  destination_ip                     = each.value.peer_keepalive.destination_ip
  source_ip                          = each.value.peer_keepalive.source_ip
  flush_timeout                      = each.value.peer_keepalive.flush_timeout
  interval                           = each.value.peer_keepalive.interval
  precedence_type                    = each.value.peer_keepalive.precedence_type
  precedence_value                   = each.value.peer_keepalive.precedence_value
  timeout                            = each.value.peer_keepalive.timeout
  type_of_service_byte               = each.value.peer_keepalive.type_of_service_byte
  type_of_service_configuration_type = each.value.peer_keepalive.type_of_service_configuration_type
  type_of_service_type               = each.value.peer_keepalive.type_of_service_type
  type_of_service_value              = each.value.peer_keepalive.type_of_service_value
  udp_port                           = each.value.peer_keepalive.udp_port
  vrf                                = each.value.peer_keepalive.vrf

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
