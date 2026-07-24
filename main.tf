locals {
  # YAML strings
  yaml_strings = concat(
    flatten([
      for dir in var.yaml_directories : [
        for file in fileset(".", "${dir}/**/*.{yml,yaml}") : file(file)
      ]
    ]),
    [for file in var.yaml_files : file(file)]
  )

  # Defaults YAML (module defaults — user overrides merged inside function)
  defaults_yaml = file("${path.module}/defaults/defaults.yaml")

  # File templates (path -> content)
  file_templates = merge(
    merge([
      for dir in var.template_directories : {
        for f in fileset(".", "${dir}/**/*") : f => file(f)
      }
    ]...),
    { for f in var.template_files : f => file(f) }
  )

  # Render device configs
  rendered = provider::utils::render_device_configs(
    local.yaml_strings,
    var.model,
    local.defaults_yaml,
    local.file_templates,
    var.managed_devices,
    var.managed_device_groups
  )

  # Derived locals
  nxos          = try(local.rendered.resolved.nxos, {})
  devices       = try(local.nxos.devices, [])
  device_config = { for device in local.devices : device.name => try(device.configuration, {}) }

  intf_prefix_map = {
    "ethernet"     = "eth"
    "loopback"     = "lo"
    "mgmt"         = "mgmt"
    "port-channel" = "po"
    "vlan"         = "vlan"
    "vni"          = "vni"
  }

  dscp_int_to_string_map = {
    0  = "default"
    8  = "cs1"
    10 = "af11"
    12 = "af12"
    14 = "af13"
    16 = "cs2"
    18 = "af21"
    20 = "af22"
    22 = "af23"
    24 = "cs3"
    26 = "af31"
    28 = "af32"
    30 = "af33"
    32 = "cs4"
    34 = "af41"
    36 = "af42"
    38 = "af43"
    40 = "cs5"
    46 = "ef"
    48 = "cs6"
    56 = "cs7"
  }
}

provider "nxos" {
  devices = local.rendered.provider_devices
}

resource "local_sensitive_file" "model" {
  count    = var.write_model_file != "" ? 1 : 0
  content  = provider::utils::yaml_encode(local.rendered.raw)
  filename = var.write_model_file
}

locals {
  cli_templates = { for order in range(10) : order => flatten([
    for device in local.devices : [
      for template in try(device.cli_templates, []) : {
        key     = format("%s/%s", device.name, template.name)
        device  = device.name
        content = template.content
      } if try(template.order, 0) == order
    ]
  ]) }
}

resource "nxos_cli" "cli_0" {
  for_each = { for e in local.cli_templates[0] : e.key => e }
  device   = each.value.device

  cli = each.value.content

  depends_on = [
    nxos_access_list.access_list,
    nxos_analytics.analytics,
    nxos_bfd.bfd,
    nxos_bgp.bgp,
    nxos_bridge_domain.bridge_domain,
    nxos_default_qos.default_qos,
    nxos_dhcp.dhcp,
    nxos_esg.esg,
    nxos_evpn.evpn,
    nxos_feature.feature,
    nxos_hardware_telemetry.hardware_telemetry,
    nxos_hmm.hmm,
    nxos_hsrp.hsrp,
    nxos_icmpv4.icmpv4,
    nxos_icmpv6.icmpv6,
    nxos_ipv4.ipv4,
    nxos_ipv6.ipv6,
    nxos_isis.isis,
    nxos_keychain.keychain,
    nxos_logging.logging,
    nxos_loopback_interface.loopback_interface,
    nxos_netflow.netflow,
    nxos_network_qos.network_qos,
    nxos_ntp.ntp,
    nxos_nvo.nvo,
    nxos_object_group.object_group,
    nxos_ospf.ospf,
    nxos_ospfv3.ospfv3,
    nxos_physical_interface.physical_interface,
    nxos_pim.pim,
    nxos_platform.platform,
    nxos_port_channel_interface.port_channel_interface,
    nxos_ptp.ptp,
    nxos_queuing_qos.queuing_qos,
    nxos_route_policy.route_policy,
    nxos_snmp.snmp,
    nxos_span.span,
    nxos_spanning_tree.spanning_tree,
    nxos_subinterface.subinterface,
    nxos_svi_interface.svi_interface,
    nxos_system.system,
    nxos_telemetry.telemetry,
    nxos_user_management.user_management,
    nxos_vpc.vpc,
    nxos_vrf.vrf,
  ]
}

resource "nxos_cli" "cli_1" {
  for_each = { for e in local.cli_templates[1] : e.key => e }
  device   = each.value.device

  cli = each.value.content

  depends_on = [
    nxos_cli.cli_0
  ]
}

resource "nxos_cli" "cli_2" {
  for_each = { for e in local.cli_templates[2] : e.key => e }
  device   = each.value.device

  cli = each.value.content

  depends_on = [
    nxos_cli.cli_1
  ]
}

resource "nxos_cli" "cli_3" {
  for_each = { for e in local.cli_templates[3] : e.key => e }
  device   = each.value.device

  cli = each.value.content

  depends_on = [
    nxos_cli.cli_2
  ]
}

resource "nxos_cli" "cli_4" {
  for_each = { for e in local.cli_templates[4] : e.key => e }
  device   = each.value.device

  cli = each.value.content

  depends_on = [
    nxos_cli.cli_3
  ]
}

resource "nxos_cli" "cli_5" {
  for_each = { for e in local.cli_templates[5] : e.key => e }
  device   = each.value.device

  cli = each.value.content

  depends_on = [
    nxos_cli.cli_4
  ]
}

resource "nxos_cli" "cli_6" {
  for_each = { for e in local.cli_templates[6] : e.key => e }
  device   = each.value.device

  cli = each.value.content

  depends_on = [
    nxos_cli.cli_5
  ]
}

resource "nxos_cli" "cli_7" {
  for_each = { for e in local.cli_templates[7] : e.key => e }
  device   = each.value.device

  cli = each.value.content

  depends_on = [
    nxos_cli.cli_6
  ]
}

resource "nxos_cli" "cli_8" {
  for_each = { for e in local.cli_templates[8] : e.key => e }
  device   = each.value.device

  cli = each.value.content

  depends_on = [
    nxos_cli.cli_7
  ]
}

resource "nxos_cli" "cli_9" {
  for_each = { for e in local.cli_templates[9] : e.key => e }
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
