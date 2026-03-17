module "model" {
  source = "./modules/model"

  yaml_directories          = var.yaml_directories
  yaml_files                = var.yaml_files
  model                     = var.model
  managed_device_groups     = var.managed_device_groups
  managed_devices           = var.managed_devices
  write_default_values_file = var.write_default_values_file
  write_model_file          = var.write_model_file
}

locals {
  model    = module.model.model
  defaults = module.model.default_values
  nxos     = try(local.model.nxos, {})
  devices  = try(local.nxos.devices, [])
  device_config = { for device in try(local.nxos.devices, []) :
    device.name => try(device.configuration, {})
  }
  provider_devices = module.model.devices
}

provider "nxos" {
  devices = local.provider_devices
}

locals {
  cli_templates_0 = flatten([
    for device in local.devices : [
      for template in try(device.cli_templates, []) : {
        key     = format("%s/%s", device.name, template.name)
        device  = device.name
        content = template.content
      } if try(template.order, local.defaults.nxos.templates.order) == 0
    ]
  ])
  cli_templates_1 = flatten([
    for device in local.devices : [
      for template in try(device.cli_templates, []) : {
        key     = format("%s/%s", device.name, template.name)
        device  = device.name
        content = template.content
      } if try(template.order, local.defaults.nxos.templates.order) == 1
    ]
  ])
  cli_templates_2 = flatten([
    for device in local.devices : [
      for template in try(device.cli_templates, []) : {
        key     = format("%s/%s", device.name, template.name)
        device  = device.name
        content = template.content
      } if try(template.order, local.defaults.nxos.templates.order) == 2
    ]
  ])
  cli_templates_3 = flatten([
    for device in local.devices : [
      for template in try(device.cli_templates, []) : {
        key     = format("%s/%s", device.name, template.name)
        device  = device.name
        content = template.content
      } if try(template.order, local.defaults.nxos.templates.order) == 3
    ]
  ])
  cli_templates_4 = flatten([
    for device in local.devices : [
      for template in try(device.cli_templates, []) : {
        key     = format("%s/%s", device.name, template.name)
        device  = device.name
        content = template.content
      } if try(template.order, local.defaults.nxos.templates.order) == 4
    ]
  ])
  cli_templates_5 = flatten([
    for device in local.devices : [
      for template in try(device.cli_templates, []) : {
        key     = format("%s/%s", device.name, template.name)
        device  = device.name
        content = template.content
      } if try(template.order, local.defaults.nxos.templates.order) == 5
    ]
  ])
  cli_templates_6 = flatten([
    for device in local.devices : [
      for template in try(device.cli_templates, []) : {
        key     = format("%s/%s", device.name, template.name)
        device  = device.name
        content = template.content
      } if try(template.order, local.defaults.nxos.templates.order) == 6
    ]
  ])
  cli_templates_7 = flatten([
    for device in local.devices : [
      for template in try(device.cli_templates, []) : {
        key     = format("%s/%s", device.name, template.name)
        device  = device.name
        content = template.content
      } if try(template.order, local.defaults.nxos.templates.order) == 7
    ]
  ])
  cli_templates_8 = flatten([
    for device in local.devices : [
      for template in try(device.cli_templates, []) : {
        key     = format("%s/%s", device.name, template.name)
        device  = device.name
        content = template.content
      } if try(template.order, local.defaults.nxos.templates.order) == 8
    ]
  ])
  cli_templates_9 = flatten([
    for device in local.devices : [
      for template in try(device.cli_templates, []) : {
        key     = format("%s/%s", device.name, template.name)
        device  = device.name
        content = template.content
      } if try(template.order, local.defaults.nxos.templates.order) == 9
    ]
  ])
}

resource "nxos_cli" "cli_0" {
  for_each = { for e in local.cli_templates_0 : e.key => e }
  device   = each.value.device

  cli = each.value.content

  depends_on = [
    nxos_access_list.access_list,
    nxos_bgp.bgp,
    nxos_bridge_domain.bridge_domain,
    nxos_default_qos.default_qos,
    nxos_dhcp.dhcp,
    nxos_evpn.evpn,
    nxos_feature.feature,
    nxos_hmm.hmm,
    nxos_hsrp.hsrp,
    nxos_icmpv4.icmpv4,
    nxos_ipv4.ipv4,
    nxos_ipv6.ipv6,
    nxos_isis.isis,
    nxos_keychain.keychain,
    nxos_logging.logging,
    nxos_loopback_interface.loopback_interface,
    nxos_ntp.ntp,
    nxos_nvo.nvo,
    nxos_ospf.ospf,
    nxos_ospfv3.ospfv3,
    nxos_physical_interface.physical_interface,
    nxos_pim.pim,
    nxos_port_channel_interface.port_channel_interface,
    nxos_queuing_qos.queuing_qos,
    nxos_route_policy.route_policy,
    nxos_spanning_tree.spanning_tree,
    nxos_subinterface.subinterface,
    nxos_svi_interface.svi_interface,
    nxos_system.system,
    nxos_user_management.user_management,
    nxos_vpc.vpc,
    nxos_vrf.vrf,
  ]
}

resource "nxos_cli" "cli_1" {
  for_each = { for e in local.cli_templates_1 : e.key => e }
  device   = each.value.device

  cli = each.value.content

  depends_on = [
    nxos_cli.cli_0
  ]
}

resource "nxos_cli" "cli_2" {
  for_each = { for e in local.cli_templates_2 : e.key => e }
  device   = each.value.device

  cli = each.value.content

  depends_on = [
    nxos_cli.cli_1
  ]
}

resource "nxos_cli" "cli_3" {
  for_each = { for e in local.cli_templates_3 : e.key => e }
  device   = each.value.device

  cli = each.value.content

  depends_on = [
    nxos_cli.cli_2
  ]
}

resource "nxos_cli" "cli_4" {
  for_each = { for e in local.cli_templates_4 : e.key => e }
  device   = each.value.device

  cli = each.value.content

  depends_on = [
    nxos_cli.cli_3
  ]
}

resource "nxos_cli" "cli_5" {
  for_each = { for e in local.cli_templates_5 : e.key => e }
  device   = each.value.device

  cli = each.value.content

  depends_on = [
    nxos_cli.cli_4
  ]
}

resource "nxos_cli" "cli_6" {
  for_each = { for e in local.cli_templates_6 : e.key => e }
  device   = each.value.device

  cli = each.value.content

  depends_on = [
    nxos_cli.cli_5
  ]
}

resource "nxos_cli" "cli_7" {
  for_each = { for e in local.cli_templates_7 : e.key => e }
  device   = each.value.device

  cli = each.value.content

  depends_on = [
    nxos_cli.cli_6
  ]
}

resource "nxos_cli" "cli_8" {
  for_each = { for e in local.cli_templates_8 : e.key => e }
  device   = each.value.device

  cli = each.value.content

  depends_on = [
    nxos_cli.cli_7
  ]
}

resource "nxos_cli" "cli_9" {
  for_each = { for e in local.cli_templates_9 : e.key => e }
  device   = each.value.device

  cli = each.value.content

  depends_on = [
    nxos_cli.cli_8
  ]
}

resource "nxos_save_config" "save_config" {
  for_each = { for device in local.devices : device.name => device if var.save_config }
  device   = each.key
  depends_on = [
    nxos_cli.cli_9
  ]
}
