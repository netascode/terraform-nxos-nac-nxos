locals {
  interfaces_ethernets_group = flatten([
    for device in local.devices : [
      for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        key           = format("%s/%s", device.name, int.id)
        configuration = yamldecode(provider::utils::yaml_merge([for g in try(int.interface_groups, []) : try([for ig in local.interface_groups : yamlencode(ig.configuration) if ig.name == g][0], "")]))
      }
    ]
  ])
  interfaces_ethernets_group_config = {
    for int in local.interfaces_ethernets_group : int.key => int.configuration
  }
  interfaces_ethernets = flatten([
    for device in local.devices : [
      for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        key                                     = format("%s/%s", device.name, int.id)
        device                                  = device.name
        id                                      = int.id
        type                                    = "eth"
        access_vlan                             = try(int.access_vlan, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].access_vlan, local.defaults.nxos.devices.configuration.interfaces.ethernets.access_vlan, 1)
        admin_state                             = try(int.admin_state, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].admin_state, local.defaults.nxos.devices.configuration.interfaces.ethernets.admin_state, false)
        auto_negotiation                        = try(int.auto_negotiation, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].auto_negotiation, local.defaults.nxos.devices.configuration.interfaces.ethernets.auto_negotiation, null)
        bandwidth                               = try(int.bandwidth, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].bandwidth, local.defaults.nxos.devices.configuration.interfaces.ethernets.bandwidth, null)
        delay                                   = try(int.delay, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].delay, local.defaults.nxos.devices.configuration.interfaces.ethernets.delay, null)
        description                             = try(int.description, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].description, local.defaults.nxos.devices.configuration.interfaces.ethernets.description, null)
        duplex                                  = try(int.duplex, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].duplex, local.defaults.nxos.devices.configuration.interfaces.ethernets.duplex, null)
        fec_mode                                = try(int.fec_mode, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].fec_mode, local.defaults.nxos.devices.configuration.interfaces.ethernets.fec_mode, null)
        layer3                                  = try(int.layer3, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].layer3, local.defaults.nxos.devices.configuration.interfaces.ethernets.layer3, false)
        link_debounce_down                      = try(int.link_debounce_down, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].link_debounce_down, local.defaults.nxos.devices.configuration.interfaces.ethernets.link_debounce_down, null)
        link_debounce_up                        = try(int.link_debounce_up, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].link_debounce_up, local.defaults.nxos.devices.configuration.interfaces.ethernets.link_debounce_up, null)
        link_logging                            = try(int.link_logging, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].link_logging, local.defaults.nxos.devices.configuration.interfaces.ethernets.link_logging, null)
        medium                                  = try(int.medium, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].medium, local.defaults.nxos.devices.configuration.interfaces.ethernets.medium, null)
        mode                                    = try(int.mode, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].mode, local.defaults.nxos.devices.configuration.interfaces.ethernets.mode, null)
        mtu                                     = try(int.mtu, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].mtu, local.defaults.nxos.devices.configuration.interfaces.ethernets.mtu, null)
        native_vlan                             = try(int.native_vlan, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].native_vlan, local.defaults.nxos.devices.configuration.interfaces.ethernets.native_vlan, 1)
        speed                                   = try(int.speed, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].speed, local.defaults.nxos.devices.configuration.interfaces.ethernets.speed, null)
        speed_group                             = try(int.speed_group, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].speed_group, local.defaults.nxos.devices.configuration.interfaces.ethernets.speed_group, null)
        trunk_vlans                             = try(int.trunk_vlans, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].trunk_vlans, local.defaults.nxos.devices.configuration.interfaces.ethernets.trunk_vlans, null)
        uni_directional_ethernet                = try(int.uni_directional_ethernet, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].uni_directional_ethernet, local.defaults.nxos.devices.configuration.interfaces.ethernets.uni_directional_ethernet, null)
        vrf                                     = try(int.vrf, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].vrf, local.defaults.nxos.devices.configuration.interfaces.ethernets.vrf, "default")
        ip_unnumbered                           = try(int.ip_unnumbered, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].ip_unnumbered, local.defaults.nxos.devices.configuration.interfaces.ethernets.ip_unnumbered, null)
        urpf                                    = try(int.urpf, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].urpf, local.defaults.nxos.devices.configuration.interfaces.ethernets.urpf, null)
        ipv4_address                            = try(int.ipv4_address, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].ipv4_address, local.defaults.nxos.devices.configuration.interfaces.ethernets.ipv4_address, null)
        ospf_process_name                       = try(int.ospf.process_name, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].ospf.process_name, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.process_name, null)
        ospf_advertise_secondaries              = try(int.ospf.advertise_secondaries, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].ospf.advertise_secondaries, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.advertise_secondaries, false)
        ospf_area                               = try(int.ospf.area, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].ospf.area, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.area, null)
        ospf_bfd                                = try(int.ospf.bfd, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].ospf.bfd, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.bfd, null)
        ospf_cost                               = try(int.ospf.cost, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].ospf.cost, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.cost, null)
        ospf_dead_interval                      = try(int.ospf.dead_interval, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].ospf.dead_interval, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.dead_interval, null)
        ospf_hello_interval                     = try(int.ospf.hello_interval, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].ospf.hello_interval, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.hello_interval, null)
        ospf_network_type                       = try(int.ospf.network_type, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].ospf.network_type, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.network_type, null)
        ospf_passive                            = try(int.ospf.passive, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].ospf.passive, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.passive, null)
        ospf_priority                           = try(int.ospf.priority, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].ospf.priority, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.priority, null)
        ospf_authentication_key                 = try(int.ospf.authentication_key, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].ospf.authentication_key, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.authentication_key, null)
        ospf_authentication_key_id              = try(int.ospf.authentication_key_id, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].ospf.authentication_key_id, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.authentication_key_id, null)
        ospf_authentication_key_secure_mode     = try(int.ospf.authentication_key_secure_mode, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].ospf.authentication_key_secure_mode, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.authentication_key_secure_mode, false)
        ospf_authentication_keychain            = try(int.ospf.authentication_keychain, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].ospf.authentication_keychain, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.authentication_keychain, null)
        ospf_authentication_md5_key             = try(int.ospf.authentication_md5_key, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].ospf.authentication_md5_key, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.authentication_md5_key, null)
        ospf_authentication_md5_key_secure_mode = try(int.ospf.authentication_md5_key_secure_mode, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].ospf.authentication_md5_key_secure_mode, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.authentication_md5_key_secure_mode, false)
        ospf_authentication_type                = try(int.ospf.authentication_type, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].ospf.authentication_type, local.defaults.nxos.devices.configuration.interfaces.ethernets.ospf.authentication_type, null)
        pim_admin_state                         = try(int.pim.admin_state, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].pim.admin_state, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.admin_state, null)
        pim_bfd                                 = try(int.pim.bfd, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].pim.bfd, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.bfd, null)
        pim_dr_priority                         = try(int.pim.dr_priority, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].pim.dr_priority, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.dr_priority, null)
        pim_passive                             = try(int.pim.passive, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].pim.passive, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.passive, null)
        pim_sparse_mode                         = try(int.pim.sparse_mode, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].pim.sparse_mode, local.defaults.nxos.devices.configuration.interfaces.ethernets.pim.sparse_mode, null)
        port_channel                            = try(int.port_channel, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].port_channel, local.defaults.nxos.devices.configuration.interfaces.ethernets.port_channel, null)
      }
    ]
  ])
  interfaces_ethernets_ipv4_secondary_addresses = flatten([
    for device in local.devices : [
      for int in try(local.device_config[device.name].interfaces.ethernets, []) : [
        for ip in try(int.ipv4_secondary_addresses, []) : {
          key           = format("%s/%s/%s", device.name, int.id, ip)
          device        = device.name
          interface_key = format("%s/%s", device.name, int.id)
          vrf           = try(int.vrf, local.interfaces_ethernets_group_config[format("%s/%s", device.name, int.id)].vrf, local.defaults.nxos.devices.configuration.interfaces.ethernets.vrf, "default")
          ip            = ip
        }
      ]
    ]
  ])
}

resource "nxos_physical_interface" "physical_interface" {
  for_each                 = { for v in local.interfaces_ethernets : v.key => v }
  device                   = each.value.device
  interface_id             = "eth${each.value.id}"
  fec_mode                 = each.value.fec_mode
  access_vlan              = each.value.layer3 ? "unknown" : "vlan-${each.value.access_vlan}"
  admin_state              = each.value.admin_state ? "up" : "down"
  auto_negotiation         = each.value.auto_negotiation
  bandwidth                = each.value.bandwidth
  delay                    = each.value.delay
  description              = each.value.description
  duplex                   = each.value.duplex
  layer                    = each.value.layer3 ? "Layer3" : "Layer2"
  link_debounce_up         = each.value.link_debounce_up
  link_debounce_down       = each.value.link_debounce_down
  link_logging             = each.value.link_logging
  medium                   = each.value.medium
  mode                     = each.value.mode
  mtu                      = each.value.mtu
  native_vlan              = each.value.layer3 ? "unknown" : "vlan-${each.value.native_vlan}"
  speed                    = each.value.speed
  speed_group              = each.value.speed_group
  trunk_vlans              = each.value.layer3 ? "1-4094" : each.value.trunk_vlans
  uni_directional_ethernet = each.value.uni_directional_ethernet
  user_configured_flags    = "admin_layer,admin_mtu,admin_state"
}

resource "nxos_physical_interface_vrf" "physical_interface_vrf" {
  for_each     = { for v in local.interfaces_ethernets : v.key => v if v.layer3 }
  device       = each.value.device
  interface_id = nxos_physical_interface.physical_interface[each.key].interface_id
  vrf_dn       = "sys/inst-${each.value.vrf}"
}

resource "nxos_ipv4_interface" "ethernet_ipv4_interface" {
  for_each     = { for v in local.interfaces_ethernets : v.key => v if v.layer3 }
  device       = each.value.device
  vrf          = each.value.vrf
  interface_id = nxos_physical_interface_vrf.physical_interface_vrf[each.key].interface_id
  unnumbered   = each.value.ip_unnumbered
  urpf         = each.value.urpf

  depends_on = [nxos_ipv4_vrf.ipv4_vrf_default]
}

resource "nxos_ipv4_interface_address" "ethernet_ipv4_interface_address" {
  for_each     = { for v in local.interfaces_ethernets : v.key => v if v.layer3 && v.ipv4_address != null }
  device       = each.value.device
  vrf          = each.value.vrf
  interface_id = nxos_ipv4_interface.ethernet_ipv4_interface[each.key].interface_id
  address      = each.value.ipv4_address
}

resource "nxos_ipv4_interface_address" "ethernet_ipv4_secondary_interface_address" {
  for_each     = { for v in local.interfaces_ethernets_ipv4_secondary_addresses : v.key => v }
  device       = each.value.device
  vrf          = each.value.vrf
  interface_id = nxos_ipv4_interface.ethernet_ipv4_interface[each.value.interface_key].interface_id
  address      = each.value.ip
  type         = "secondary"

  depends_on = [
    nxos_ipv4_interface_address.ethernet_ipv4_interface_address
  ]
}

locals {
  interfaces_port_channels_group = flatten([
    for device in local.devices : [
      for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        key           = format("%s/%s", device.name, int.id)
        configuration = yamldecode(provider::utils::yaml_merge([for g in try(int.interface_groups, []) : try([for ig in local.interface_groups : yamlencode(ig.configuration) if ig.name == g][0], "")]))
      }
    ]
  ])
  interfaces_port_channels_group_config = {
    for int in local.interfaces_port_channels_group : int.key => int.configuration
  }
  interfaces_port_channels = flatten([
    for device in local.devices : [
      for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        key                      = format("%s/%s", device.name, int.id)
        device                   = device.name
        id                       = int.id
        type                     = "po"
        port_channel_mode        = try(int.port_channel_mode, local.interfaces_port_channels_group_config[format("%s/%s", device.name, int.id)].port_channel_mode, local.defaults.nxos.devices.configuration.interfaces.port_channels.port_channel_mode, "on")
        minimum_links            = try(int.minimum_links, local.interfaces_port_channels_group_config[format("%s/%s", device.name, int.id)].minimum_links, local.defaults.nxos.devices.configuration.interfaces.port_channels.minimum_links, 1)
        maximum_links            = try(int.maximum_links, local.interfaces_port_channels_group_config[format("%s/%s", device.name, int.id)].maximum_links, local.defaults.nxos.devices.configuration.interfaces.port_channels.maximum_links, 32)
        suspend_individual       = try(int.suspend_individual, local.interfaces_port_channels_group_config[format("%s/%s", device.name, int.id)].suspend_individual, local.defaults.nxos.devices.configuration.interfaces.port_channels.suspend_individual, "enable")
        access_vlan              = try(int.access_vlan, local.interfaces_port_channels_group_config[format("%s/%s", device.name, int.id)].access_vlan, local.defaults.nxos.devices.configuration.interfaces.port_channels.access_vlan, 1)
        admin_state              = try(int.admin_state, local.interfaces_port_channels_group_config[format("%s/%s", device.name, int.id)].admin_state, local.defaults.nxos.devices.configuration.interfaces.port_channels.admin_state, false)
        auto_negotiation         = try(int.auto_negotiation, local.interfaces_port_channels_group_config[format("%s/%s", device.name, int.id)].auto_negotiation, local.defaults.nxos.devices.configuration.interfaces.port_channels.auto_negotiation, null)
        bandwidth                = try(int.bandwidth, local.interfaces_port_channels_group_config[format("%s/%s", device.name, int.id)].bandwidth, local.defaults.nxos.devices.configuration.interfaces.port_channels.bandwidth, null)
        delay                    = try(int.delay, local.interfaces_port_channels_group_config[format("%s/%s", device.name, int.id)].delay, local.defaults.nxos.devices.configuration.interfaces.port_channels.delay, null)
        description              = try(int.description, local.interfaces_port_channels_group_config[format("%s/%s", device.name, int.id)].description, local.defaults.nxos.devices.configuration.interfaces.port_channels.description, null)
        duplex                   = try(int.duplex, local.interfaces_port_channels_group_config[format("%s/%s", device.name, int.id)].duplex, local.defaults.nxos.devices.configuration.interfaces.port_channels.duplex, null)
        layer3                   = try(int.layer3, local.interfaces_port_channels_group_config[format("%s/%s", device.name, int.id)].layer3, local.defaults.nxos.devices.configuration.interfaces.port_channels.layer3, false)
        link_logging             = try(int.link_logging, local.interfaces_port_channels_group_config[format("%s/%s", device.name, int.id)].link_logging, local.defaults.nxos.devices.configuration.interfaces.port_channels.link_logging, null)
        medium                   = try(int.medium, local.interfaces_port_channels_group_config[format("%s/%s", device.name, int.id)].medium, local.defaults.nxos.devices.configuration.interfaces.port_channels.medium, null)
        mode                     = try(int.mode, local.interfaces_port_channels_group_config[format("%s/%s", device.name, int.id)].mode, local.defaults.nxos.devices.configuration.interfaces.port_channels.mode, null)
        mtu                      = try(int.mtu, local.interfaces_port_channels_group_config[format("%s/%s", device.name, int.id)].mtu, local.defaults.nxos.devices.configuration.interfaces.port_channels.mtu, null)
        native_vlan              = try(int.native_vlan, local.interfaces_port_channels_group_config[format("%s/%s", device.name, int.id)].native_vlan, local.defaults.nxos.devices.configuration.interfaces.port_channels.native_vlan, 1)
        speed                    = try(int.speed, local.interfaces_port_channels_group_config[format("%s/%s", device.name, int.id)].speed, local.defaults.nxos.devices.configuration.interfaces.port_channels.speed, null)
        trunk_vlans              = try(int.trunk_vlans, local.interfaces_port_channels_group_config[format("%s/%s", device.name, int.id)].trunk_vlans, local.defaults.nxos.devices.configuration.interfaces.port_channels.trunk_vlans, null)
        vrf                      = try(int.vrf, local.interfaces_port_channels_group_config[format("%s/%s", device.name, int.id)].vrf, local.defaults.nxos.devices.configuration.interfaces.port_channels.vrf, "default")
        ip_unnumbered            = try(int.ip_unnumbered, local.interfaces_port_channels_group_config[format("%s/%s", device.name, int.id)].ip_unnumbered, local.defaults.nxos.devices.configuration.interfaces.port_channels.ip_unnumbered, null)
        urpf                     = try(int.urpf, local.interfaces_port_channels_group_config[format("%s/%s", device.name, int.id)].urpf, local.defaults.nxos.devices.configuration.interfaces.port_channels.urpf, null)
        ipv4_address             = try(int.ipv4_address, local.interfaces_port_channels_group_config[format("%s/%s", device.name, int.id)].ipv4_address, local.defaults.nxos.devices.configuration.interfaces.port_channels.ipv4_address, null)
        ipv4_secondary_addresses = try(int.ipv4_secondary_addresses, local.interfaces_port_channels_group_config[format("%s/%s", device.name, int.id)].ipv4_secondary_addresses, local.defaults.nxos.devices.configuration.interfaces.port_channels.ipv4_secondary_addresses, [])
      }
    ]
  ])
  interfaces_port_channels_ipv4_secondary_addresses = flatten([
    for device in local.devices : [
      for int in try(local.device_config[device.name].interfaces.port_channels, []) : [
        for ip in try(int.ipv4_secondary_addresses, []) : {
          key           = format("%s/%s/%s", device.name, int.id, ip)
          device        = device.name
          interface_key = format("%s/%s", device.name, int.id)
          vrf           = try(int.vrf, local.interfaces_port_channels_group_config[format("%s/%s", device.name, int.id)].vrf, local.defaults.nxos.devices.configuration.interfaces.port_channels.vrf, "default")
          ip            = ip
        }
      ]
    ]
  ])
}

resource "nxos_port_channel_interface" "port_channel_interface" {
  for_each              = { for v in local.interfaces_port_channels : v.key => v }
  device                = each.value.device
  interface_id          = "po${each.value.id}"
  port_channel_mode     = each.value.port_channel_mode
  minimum_links         = each.value.minimum_links
  maximum_links         = each.value.maximum_links
  suspend_individual    = each.value.suspend_individual
  access_vlan           = each.value.layer3 ? "unknown" : "vlan-${each.value.access_vlan}"
  admin_state           = each.value.admin_state ? "up" : "down"
  auto_negotiation      = each.value.auto_negotiation
  bandwidth             = each.value.bandwidth
  delay                 = each.value.delay
  description           = each.value.description
  duplex                = each.value.duplex
  layer                 = each.value.layer3 ? "Layer3" : "Layer2"
  link_logging          = each.value.link_logging
  medium                = each.value.medium
  mode                  = each.value.mode
  mtu                   = each.value.mtu
  native_vlan           = each.value.layer3 ? "unknown" : "vlan-${each.value.native_vlan}"
  speed                 = each.value.speed
  trunk_vlans           = each.value.layer3 ? "1-4094" : each.value.trunk_vlans
  user_configured_flags = "admin_layer,admin_mtu,admin_state"
}

resource "nxos_port_channel_interface_vrf" "port_channel_interface_vrf" {
  for_each     = { for v in local.interfaces_port_channels : v.key => v if v.layer3 }
  device       = each.value.device
  interface_id = "po${each.value.id}"
  vrf_dn       = "sys/inst-${each.value.vrf}"
}

resource "nxos_ipv4_interface" "port_channel_ipv4_interface" {
  for_each     = { for v in local.interfaces_port_channels : v.key => v if v.layer3 }
  device       = each.value.device
  vrf          = each.value.vrf
  interface_id = nxos_port_channel_interface_vrf.port_channel_interface_vrf[each.key].interface_id
  unnumbered   = each.value.ip_unnumbered
  urpf         = each.value.urpf

  depends_on = [nxos_ipv4_vrf.ipv4_vrf_default]
}

resource "nxos_ipv4_interface_address" "port_channel_ipv4_interface_address" {
  for_each     = { for v in local.interfaces_port_channels : v.key => v if v.layer3 && v.ipv4_address != null }
  device       = each.value.device
  vrf          = each.value.vrf
  interface_id = nxos_ipv4_interface.port_channel_ipv4_interface[each.key].interface_id
  address      = each.value.ipv4_address
}

resource "nxos_ipv4_interface_address" "port_channel_ipv4_secondary_interface_address" {
  for_each     = { for v in local.interfaces_port_channels_ipv4_secondary_addresses : v.key => v }
  device       = each.value.device
  vrf          = each.value.vrf
  interface_id = nxos_ipv4_interface.port_channel_ipv4_interface[each.value.interface_key].interface_id
  address      = each.value.ip
  type         = "secondary"

  depends_on = [
    nxos_ipv4_interface_address.port_channel_ipv4_interface_address
  ]
}

resource "nxos_port_channel_interface_member" "port_channel_interface_member" {
  for_each     = { for v in local.interfaces_ethernets : v.key => v if v.port_channel != null }
  device       = each.value.device
  interface_id = "po${each.value.port_channel}"
  interface_dn = "sys/intf/phys-[${nxos_physical_interface.physical_interface[each.key].interface_id}]"
  force        = false
  depends_on   = [nxos_port_channel_interface.port_channel_interface]
}

locals {
  interfaces_loopbacks_group = flatten([
    for device in local.devices : [
      for int in try(local.device_config[device.name].interfaces.loopbacks, []) : {
        key           = format("%s/%s", device.name, int.id)
        configuration = yamldecode(provider::utils::yaml_merge([for g in try(int.interface_groups, []) : try([for ig in local.interface_groups : yamlencode(ig.configuration) if ig.name == g][0], "")]))
      }
    ]
  ])
  interfaces_loopbacks_group_config = {
    for int in local.interfaces_loopbacks_group : int.key => int.configuration
  }
  interfaces_loopbacks = flatten([
    for device in local.devices : [
      for int in try(local.device_config[device.name].interfaces.loopbacks, []) : {
        key                                     = format("%s/%s", device.name, int.id)
        device                                  = device.name
        id                                      = int.id
        type                                    = "lo"
        admin_state                             = try(int.admin_state, local.interfaces_loopbacks_group_config[format("%s/%s", device.name, int.id)].admin_state, local.defaults.nxos.devices.configuration.interfaces.loopbacks.admin_state, false)
        description                             = try(int.description, local.interfaces_loopbacks_group_config[format("%s/%s", device.name, int.id)].description, local.defaults.nxos.devices.configuration.interfaces.loopbacks.description, null)
        vrf                                     = try(int.vrf, local.interfaces_loopbacks_group_config[format("%s/%s", device.name, int.id)].vrf, local.defaults.nxos.devices.configuration.interfaces.loopbacks.vrf, "default")
        ipv4_address                            = try(int.ipv4_address, local.interfaces_loopbacks_group_config[format("%s/%s", device.name, int.id)].ipv4_address, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ipv4_address, null)
        ospf_process_name                       = try(int.ospf.process_name, local.interfaces_loopbacks_group_config[format("%s/%s", device.name, int.id)].ospf.process_name, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.process_name, null)
        ospf_advertise_secondaries              = try(int.ospf.advertise_secondaries, local.interfaces_loopbacks_group_config[format("%s/%s", device.name, int.id)].ospf.advertise_secondaries, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.advertise_secondaries, false)
        ospf_area                               = try(int.ospf.area, local.interfaces_loopbacks_group_config[format("%s/%s", device.name, int.id)].ospf.area, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.area, null)
        ospf_bfd                                = try(int.ospf.bfd, local.interfaces_loopbacks_group_config[format("%s/%s", device.name, int.id)].ospf.bfd, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.bfd, null)
        ospf_cost                               = try(int.ospf.cost, local.interfaces_loopbacks_group_config[format("%s/%s", device.name, int.id)].ospf.cost, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.cost, null)
        ospf_dead_interval                      = try(int.ospf.dead_interval, local.interfaces_loopbacks_group_config[format("%s/%s", device.name, int.id)].ospf.dead_interval, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.dead_interval, null)
        ospf_hello_interval                     = try(int.ospf.hello_interval, local.interfaces_loopbacks_group_config[format("%s/%s", device.name, int.id)].ospf.hello_interval, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.hello_interval, null)
        ospf_network_type                       = try(int.ospf.network_type, local.interfaces_loopbacks_group_config[format("%s/%s", device.name, int.id)].ospf.network_type, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.network_type, null)
        ospf_passive                            = try(int.ospf.passive, local.interfaces_loopbacks_group_config[format("%s/%s", device.name, int.id)].ospf.passive, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.passive, null)
        ospf_priority                           = try(int.ospf.priority, local.interfaces_loopbacks_group_config[format("%s/%s", device.name, int.id)].ospf.priority, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.priority, null)
        ospf_authentication_key                 = try(int.ospf.authentication_key, local.interfaces_loopbacks_group_config[format("%s/%s", device.name, int.id)].ospf.authentication_key, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.authentication_key, null)
        ospf_authentication_key_id              = try(int.ospf.authentication_key_id, local.interfaces_loopbacks_group_config[format("%s/%s", device.name, int.id)].ospf.authentication_key_id, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.authentication_key_id, null)
        ospf_authentication_key_secure_mode     = try(int.ospf.authentication_key_secure_mode, local.interfaces_loopbacks_group_config[format("%s/%s", device.name, int.id)].ospf.authentication_key_secure_mode, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.authentication_key_secure_mode, false)
        ospf_authentication_keychain            = try(int.ospf.authentication_keychain, local.interfaces_loopbacks_group_config[format("%s/%s", device.name, int.id)].ospf.authentication_keychain, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.authentication_keychain, null)
        ospf_authentication_md5_key             = try(int.ospf.authentication_md5_key, local.interfaces_loopbacks_group_config[format("%s/%s", device.name, int.id)].ospf.authentication_md5_key, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.authentication_md5_key, null)
        ospf_authentication_md5_key_secure_mode = try(int.ospf.authentication_md5_key_secure_mode, local.interfaces_loopbacks_group_config[format("%s/%s", device.name, int.id)].ospf.authentication_md5_key_secure_mode, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.authentication_md5_key_secure_mode, false)
        ospf_authentication_type                = try(int.ospf.authentication_type, local.interfaces_loopbacks_group_config[format("%s/%s", device.name, int.id)].ospf.authentication_type, local.defaults.nxos.devices.configuration.interfaces.loopbacks.ospf.authentication_type, null)
        pim_admin_state                         = try(int.pim.admin_state, local.interfaces_loopbacks_group_config[format("%s/%s", device.name, int.id)].pim.admin_state, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.admin_state, null)
        pim_bfd                                 = try(int.pim.bfd, local.interfaces_loopbacks_group_config[format("%s/%s", device.name, int.id)].pim.bfd, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.bfd, null)
        pim_dr_priority                         = try(int.pim.dr_priority, local.interfaces_loopbacks_group_config[format("%s/%s", device.name, int.id)].pim.dr_priority, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.dr_priority, null)
        pim_passive                             = try(int.pim.passive, local.interfaces_loopbacks_group_config[format("%s/%s", device.name, int.id)].pim.passive, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.passive, null)
        pim_sparse_mode                         = try(int.pim.sparse_mode, local.interfaces_loopbacks_group_config[format("%s/%s", device.name, int.id)].pim.sparse_mode, local.defaults.nxos.devices.configuration.interfaces.loopbacks.pim.sparse_mode, null)
      }
    ]
  ])
  interfaces_loopbacks_ipv4_secondary_addresses = flatten([
    for device in local.devices : [
      for int in try(local.device_config[device.name].interfaces.loopbacks, []) : [
        for ip in try(int.ipv4_secondary_addresses, []) : {
          key           = format("%s/%s/%s", device.name, int.id, ip)
          device        = device.name
          interface_key = format("%s/%s", device.name, int.id)
          vrf           = try(int.vrf, local.interfaces_loopbacks_group_config[format("%s/%s", device.name, int.id)].vrf, local.defaults.nxos.devices.configuration.interfaces.loopbacks.vrf, "default")
          ip            = ip
        }
      ]
    ]
  ])
}

resource "nxos_loopback_interface" "loopback_interface" {
  for_each     = { for v in local.interfaces_loopbacks : v.key => v }
  device       = each.value.device
  interface_id = "lo${each.value.id}"
  admin_state  = each.value.admin_state ? "up" : "down"
  description  = each.value.description
}

resource "nxos_loopback_interface_vrf" "loopback_interface_vrf" {
  for_each     = { for v in local.interfaces_loopbacks : v.key => v }
  device       = each.value.device
  interface_id = nxos_loopback_interface.loopback_interface[each.key].interface_id
  vrf_dn       = "sys/inst-${each.value.vrf}"
}

resource "nxos_ipv4_interface" "loopback_ipv4_interface" {
  for_each     = { for v in local.interfaces_loopbacks : v.key => v }
  device       = each.value.device
  vrf          = each.value.vrf
  interface_id = nxos_loopback_interface_vrf.loopback_interface_vrf[each.key].interface_id

  depends_on = [nxos_ipv4_vrf.ipv4_vrf_default]
}

resource "nxos_ipv4_interface_address" "loopback_ipv4_interface_address" {
  for_each     = { for v in local.interfaces_loopbacks : v.key => v if v.ipv4_address != null }
  device       = each.value.device
  vrf          = each.value.vrf
  interface_id = nxos_ipv4_interface.loopback_ipv4_interface[each.key].interface_id
  address      = each.value.ipv4_address
  type         = "primary"
}

resource "nxos_ipv4_interface_address" "loopback_ipv4_secondary_interface_address" {
  for_each     = { for v in local.interfaces_loopbacks_ipv4_secondary_addresses : v.key => v }
  device       = each.value.device
  vrf          = each.value.vrf
  interface_id = nxos_ipv4_interface.loopback_ipv4_interface[each.value.interface_key].interface_id
  address      = each.value.ip
  type         = "secondary"

  depends_on = [
    nxos_ipv4_interface_address.loopback_ipv4_interface_address
  ]
}

locals {
  interfaces_vlans_group = flatten([
    for device in local.devices : [
      for int in try(local.device_config[device.name].interfaces.vlans, []) : {
        key           = format("%s/%s", device.name, int.id)
        configuration = yamldecode(provider::utils::yaml_merge([for g in try(int.interface_groups, []) : try([for ig in local.interface_groups : yamlencode(ig.configuration) if ig.name == g][0], "")]))
      }
    ]
  ])
  interfaces_vlans_group_config = {
    for int in local.interfaces_vlans_group : int.key => int.configuration
  }
  interfaces_vlans = flatten([
    for device in local.devices : [
      for int in try(local.device_config[device.name].interfaces.vlans, []) : {
        key                                     = format("%s/%s", device.name, int.id)
        device                                  = device.name
        id                                      = int.id
        type                                    = "vlan"
        admin_state                             = try(int.admin_state, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].admin_state, local.defaults.nxos.devices.configuration.interfaces.vlans.admin_state, false)
        description                             = try(int.description, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].description, local.defaults.nxos.devices.configuration.interfaces.vlans.description, null)
        vrf                                     = try(int.vrf, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].vrf, local.defaults.nxos.devices.configuration.interfaces.vlans.vrf, "default")
        ipv4_address                            = try(int.ipv4_address, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].ipv4_address, local.defaults.nxos.devices.configuration.interfaces.vlans.ipv4_address, null)
        delay                                   = try(int.delay, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].delay, local.defaults.nxos.devices.configuration.interfaces.vlans.delay, null)
        bandwidth                               = try(int.bandwidth, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].bandwidth, local.defaults.nxos.devices.configuration.interfaces.vlans.bandwidth, null)
        ip_forward                              = try(int.ip_forward, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].ip_forward, local.defaults.nxos.devices.configuration.interfaces.vlans.ip_forward, false)
        ip_drop_glean                           = try(int.ip_drop_glean, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].ip_drop_glean, local.defaults.nxos.devices.configuration.interfaces.vlans.ip_drop_glean, false)
        medium                                  = try(int.medium, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].medium, local.defaults.nxos.devices.configuration.interfaces.vlans.medium, null)
        mtu                                     = try(int.mtu, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].mtu, local.defaults.nxos.devices.configuration.interfaces.vlans.mtu, null)
        fabric_forwarding_mode                  = try(int.fabric_forwarding_mode, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].fabric_forwarding_mode, local.defaults.nxos.devices.configuration.interfaces.vlans.fabric_forwarding_mode, null)
        ospf_process_name                       = try(int.ospf.process_name, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].ospf.process_name, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.process_name, null)
        ospf_advertise_secondaries              = try(int.ospf.advertise_secondaries, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].ospf.advertise_secondaries, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.advertise_secondaries, false)
        ospf_area                               = try(int.ospf.area, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].ospf.area, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.area, null)
        ospf_bfd                                = try(int.ospf.bfd, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].ospf.bfd, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.bfd, null)
        ospf_cost                               = try(int.ospf.cost, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].ospf.cost, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.cost, null)
        ospf_dead_interval                      = try(int.ospf.dead_interval, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].ospf.dead_interval, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.dead_interval, null)
        ospf_hello_interval                     = try(int.ospf.hello_interval, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].ospf.hello_interval, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.hello_interval, null)
        ospf_network_type                       = try(int.ospf.network_type, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].ospf.network_type, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.network_type, null)
        ospf_passive                            = try(int.ospf.passive, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].ospf.passive, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.passive, null)
        ospf_priority                           = try(int.ospf.priority, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].ospf.priority, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.priority, null)
        ospf_authentication_key                 = try(int.ospf.authentication_key, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].ospf.authentication_key, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.authentication_key, null)
        ospf_authentication_key_id              = try(int.ospf.authentication_key_id, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].ospf.authentication_key_id, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.authentication_key_id, null)
        ospf_authentication_key_secure_mode     = try(int.ospf.authentication_key_secure_mode, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].ospf.authentication_key_secure_mode, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.authentication_key_secure_mode, false)
        ospf_authentication_keychain            = try(int.ospf.authentication_keychain, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].ospf.authentication_keychain, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.authentication_keychain, null)
        ospf_authentication_md5_key             = try(int.ospf.authentication_md5_key, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].ospf.authentication_md5_key, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.authentication_md5_key, null)
        ospf_authentication_md5_key_secure_mode = try(int.ospf.authentication_md5_key_secure_mode, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].ospf.authentication_md5_key_secure_mode, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.authentication_md5_key_secure_mode, false)
        ospf_authentication_type                = try(int.ospf.authentication_type, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].ospf.authentication_type, local.defaults.nxos.devices.configuration.interfaces.vlans.ospf.authentication_type, null)
        pim_admin_state                         = try(int.pim.admin_state, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].pim.admin_state, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.admin_state, null)
        pim_bfd                                 = try(int.pim.bfd, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].pim.bfd, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.bfd, null)
        pim_dr_priority                         = try(int.pim.dr_priority, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].pim.dr_priority, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.dr_priority, null)
        pim_passive                             = try(int.pim.passive, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].pim.passive, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.passive, null)
        pim_sparse_mode                         = try(int.pim.sparse_mode, local.interfaces_vlans_group_config[format("%s/%s", device.name, int.id)].pim.sparse_mode, local.defaults.nxos.devices.configuration.interfaces.vlans.pim.sparse_mode, null)
      }
    ]
  ])
  interfaces_vlans_ipv4_secondary_addresses = flatten([
    for device in local.devices : [
      for int in try(local.device_config[device.name].interfaces.vlans, []) : [
        for ip in try(int.ipv4_secondary_addresses, []) : {
          key           = format("%s/%s/%s", device.name, int.id, ip)
          device        = device.name
          interface_key = format("%s/%s", device.name, int.id)
          ip            = ip
        }
      ]
    ]
  ])
}

resource "nxos_svi_interface" "svi_interface" {
  for_each     = { for v in local.interfaces_vlans : v.key => v }
  device       = each.value.device
  interface_id = "vlan${each.value.id}"
  admin_state  = each.value.admin_state ? "up" : "down"
  description  = each.value.description
  bandwidth    = each.value.bandwidth
  delay        = each.value.delay
  medium       = each.value.medium
  mtu          = each.value.mtu
}

resource "nxos_svi_interface_vrf" "svi_interface_vrf" {
  for_each     = { for v in local.interfaces_vlans : v.key => v }
  device       = each.value.device
  interface_id = nxos_svi_interface.svi_interface[each.key].interface_id
  vrf_dn       = "sys/inst-${each.value.vrf}"
}

resource "nxos_ipv4_interface" "svi_ipv4_interface" {
  for_each     = { for v in local.interfaces_vlans : v.key => v }
  device       = each.value.device
  vrf          = each.value.vrf
  interface_id = nxos_svi_interface_vrf.svi_interface_vrf[each.key].interface_id
  forward      = each.value.ip_forward ? "enabled" : "disabled"
  drop_glean   = each.value.ip_drop_glean ? "enabled" : "disabled"

  depends_on = [nxos_ipv4_vrf.ipv4_vrf_default]
}

resource "nxos_ipv4_interface_address" "svi_ipv4_interface_address" {
  for_each     = { for v in local.interfaces_vlans : v.key => v if v.ipv4_address != null }
  device       = each.value.device
  vrf          = each.value.vrf
  interface_id = nxos_ipv4_interface.svi_ipv4_interface[each.key].interface_id
  address      = each.value.ipv4_address
  type         = "primary"
}

resource "nxos_ipv4_interface_address" "svi_ipv4_secondary_interface_address" {
  for_each     = { for v in local.interfaces_vlans_ipv4_secondary_addresses : v.key => v }
  device       = each.value.device
  vrf          = each.value.vrf
  interface_id = nxos_ipv4_interface.svi_ipv4_interface[each.value.interface_key].interface_id
  address      = each.value.ip
  type         = "secondary"

  depends_on = [
    nxos_ipv4_interface_address.svi_ipv4_interface_address
  ]
}

locals {
  interfaces_nve_vnis = flatten([
    for device in local.devices : [
      for vni in try(local.device_config[device.name].interfaces.nve.vnis, []) : {
        key                           = format("%s/%s", device.name, vni.vni)
        device                        = device.name
        vni                           = vni.vni
        associate_vrf                 = try(vni.associate_vrf, local.defaults.nxos.devices.configuration.interfaces.nve.vnis.associate_vrf, null)
        multicast_group               = try(vni.multicast_group, local.defaults.nxos.devices.configuration.interfaces.nve.vnis.multicast_group, null)
        multisite_ingress_replication = try(vni.multisite_ingress_replication, local.defaults.nxos.devices.configuration.interfaces.nve.vnis.multisite_ingress_replication, null)
        suppress_arp                  = try(vni.suppress_arp, local.defaults.nxos.devices.configuration.interfaces.nve.vnis.suppress_arp, null)
        ingress_replication_protocol  = try(vni.ingress_replication_protocol, local.defaults.nxos.devices.configuration.interfaces.nve.vnis.ingress_replication_protocol, null)
      }
    ]
  ])
}

resource "nxos_nve_interface" "nve_interface" {
  for_each                         = { for v in local.devices : v.name => v if try(local.device_config[v.name].interfaces.nve, null) != null }
  device                           = each.key
  admin_state                      = try(local.device_config[each.key].interfaces.nve.admin_state, local.defaults.nxos.devices.configuration.interfaces.nve.admin_state, false) ? "enabled" : "disabled"
  advertise_virtual_mac            = try(local.device_config[each.key].interfaces.nve.advertise_virtual_mac, local.defaults.nxos.devices.configuration.interfaces.nve.advertise_virtual_mac, false)
  hold_down_time                   = try(local.device_config[each.key].interfaces.nve.hold_down_time, local.defaults.nxos.devices.configuration.interfaces.nve.hold_down_time, null)
  host_reachability_protocol       = try(local.device_config[each.key].interfaces.nve.host_reachability_protocol, local.defaults.nxos.devices.configuration.interfaces.nve.host_reachability_protocol, null)
  ingress_replication_protocol_bgp = try(local.device_config[each.key].interfaces.nve.ingress_replication_protocol_bgp, local.defaults.nxos.devices.configuration.interfaces.nve.ingress_replication_protocol_bgp, false)
  multicast_group_l2               = try(local.device_config[each.key].interfaces.nve.multicast_group_l2, local.defaults.nxos.devices.configuration.interfaces.nve.multicast_group_l2, null)
  multicast_group_l3               = try(local.device_config[each.key].interfaces.nve.multicast_group_l3, local.defaults.nxos.devices.configuration.interfaces.nve.multicast_group_l3, null)
  multisite_source_interface       = try(local.device_config[each.key].interfaces.nve.multisite_source_interface, local.defaults.nxos.devices.configuration.interfaces.nve.multisite_source_interface, null)
  source_interface                 = try(local.device_config[each.key].interfaces.nve.source_interface, local.defaults.nxos.devices.configuration.interfaces.nve.source_interface, null)
  suppress_arp                     = try(local.device_config[each.key].interfaces.nve.suppress_arp, local.defaults.nxos.devices.configuration.interfaces.nve.suppress_arp, false)
  suppress_mac_route               = try(local.device_config[each.key].interfaces.nve.suppress_mac_route, local.defaults.nxos.devices.configuration.interfaces.nve.suppress_mac_route, false)

  depends_on = [
    nxos_feature_nv_overlay.nv_overlay
  ]
}

resource "nxos_nve_vni_container" "nve_vni_container" {
  for_each = { for v in local.devices : v.name => v if try(local.device_config[v.name].interfaces.nve, null) != null }
  device   = each.key

  depends_on = [
    nxos_nve_interface.nve_interface
  ]
}

resource "nxos_nve_vni" "nve_vni" {
  for_each                      = { for v in local.interfaces_nve_vnis : v.key => v }
  device                        = each.value.device
  vni                           = each.value.vni
  associate_vrf                 = each.value.associate_vrf
  multicast_group               = each.value.multicast_group
  multisite_ingress_replication = each.value.multisite_ingress_replication
  suppress_arp                  = each.value.suppress_arp

  depends_on = [
    nxos_nve_vni_container.nve_vni_container
  ]
}

resource "nxos_nve_vni_ingress_replication" "nve_vni_ingress_replication" {
  for_each = { for v in local.interfaces_nve_vnis : v.key => v if v.ingress_replication_protocol != null }
  device   = each.value.device
  vni      = nxos_nve_vni.nve_vni[each.key].vni
  protocol = each.value.ingress_replication_protocol
}
