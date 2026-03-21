locals {
  nxos                    = try(local.model.nxos, {})
  global                  = try(local.nxos.global, [])
  devices                 = try(local.nxos.devices, [])
  device_groups           = try(local.nxos.device_groups, [])
  interface_groups        = try(local.nxos.interface_groups, [])
  configuration_templates = try(local.nxos.configuration_templates, [])
  templates               = { for template in try(local.nxos.templates, []) : template.name => template }

  all_devices = [for device in local.devices : {
    name    = device.name
    url     = device.url
    managed = try(device.managed, local.defaults.nxos.devices.managed, true)
  }]

  managed_devices = [
    for device in local.devices : device if(length(var.managed_devices) == 0 || contains(var.managed_devices, device.name)) && (length(var.managed_device_groups) == 0 || anytrue([for dg in local.device_groups : contains(try(device.device_groups, []), dg.name) && contains(var.managed_device_groups, dg.name)]) || anytrue([for dg in local.device_groups : contains(try(dg.devices, []), device.name) && contains(var.managed_device_groups, dg.name)]))
  ]

  device_variables = { for device in local.managed_devices :
    device.name => merge(concat(
      [try(local.global.variables, {})],
      [for dg in local.device_groups : try(dg.variables, {}) if contains(try(device.device_groups, []), dg.name)],
      [for dg in local.device_groups : try(dg.variables, {}) if contains(try(dg.devices, []), device.name)],
      [try(device.variables, {})]
    )...)
  }

  device_group_variables = { for dg in local.device_groups :
    dg.name => try(dg.variables, {})
  }

  device_config_templates_raw_config = { for device in local.managed_devices :
    device.name => {
      for dg in local.device_groups : dg.name => [
        for t in try(dg.configuration_templates, []) :
        yamlencode(try([for ct in local.configuration_templates : try(ct.configuration, {}) if ct.name == t][0], {}))
      ]
      if contains(try(device.device_groups, []), dg.name) || contains(try(dg.devices, []), device.name)
    }
  }

  device_config_templates_config = { for device, groups in local.device_config_templates_raw_config :
    device => provider::utils::yaml_merge([
      for group_name, group_configs in groups : provider::utils::yaml_merge(
        [for config in group_configs : templatestring(config, merge(local.device_variables[device], local.device_group_variables[group_name]))]
      )
    ])
  }

  devices_raw_config = { for device in local.managed_devices :
    device.name => try(provider::utils::yaml_merge(concat(
      [yamlencode(try(local.global.configuration, {}))],
      [for dg in local.device_groups : yamlencode(try(dg.configuration, {})) if contains(try(device.device_groups, []), dg.name)],
      [for dg in local.device_groups : yamlencode(try(dg.configuration, {})) if contains(try(dg.devices, []), device.name)],
      [local.device_config_templates_config[device.name]],
      [yamlencode(try(device.configuration, {}))]
    )), "")
  }

  device_config = { for device, config in local.devices_raw_config :
    device => yamldecode(templatestring(config, local.device_variables[device]))
  }

  interface_groups_raw_config = {
    for device in local.managed_devices : device.name => {
      for ig in local.interface_groups : ig.name => yamlencode(try(ig.configuration, {}))
    }
  }

  interface_groups_config = {
    for device in local.managed_devices : device.name => [
      for ig in local.interface_groups : {
        name          = ig.name
        configuration = yamldecode(templatestring(local.interface_groups_raw_config[device.name][ig.name], local.device_variables[device.name]))
      }
    ]
  }

  global_cli_templates_raw = { for device in local.managed_devices :
    device.name => {
      for t in try(local.global.templates, []) : local.templates[t].name => {
        content = local.templates[t].content
        order   = try(local.templates[t].order, local.defaults.nxos.templates.order)
      } if try(local.templates[t].type, null) == "cli" && try(local.templates[t].content, "") != ""
    }
  }

  global_cli_templates = { for device, templates in local.global_cli_templates_raw :
    device => { for name, template in templates : name => {
      content = templatestring(template.content, local.device_variables[device])
      order   = template.order
    } }
  }

  group_cli_templates_raw = { for device in local.managed_devices :
    device.name => {
      for dg in local.device_groups : dg.name => {
        for t in try(dg.templates, []) : "${local.templates[t].name}/${dg.name}" => {
          content = local.templates[t].content
          order   = try(local.templates[t].order, local.defaults.nxos.templates.order)
        } if try(local.templates[t].type, null) == "cli" && try(local.templates[t].content, "") != ""
      }
      if contains(try(device.device_groups, []), dg.name) || contains(try(dg.devices, []), device.name)
    }
  }

  group_cli_templates = { for device, groups in local.group_cli_templates_raw :
    device => merge([
      for group_name, group_configs in groups : {
        for name, template in group_configs : name => {
          content = templatestring(template.content, merge(local.device_variables[device], [for dg in local.device_groups : try(dg.variables, {}) if group_name == dg.name][0]))
          order   = template.order
        }
      }
    ]...)
  }

  device_cli_templates_raw = { for device in local.managed_devices :
    device.name => {
      for t in try(device.templates, []) : local.templates[t].name => {
        content = local.templates[t].content
        order   = try(local.templates[t].order, local.defaults.nxos.templates.order)
      } if try(local.templates[t].type, null) == "cli" && try(local.templates[t].content, "") != ""
    }
  }

  device_cli_templates = { for device, configs in local.device_cli_templates_raw :
    device => { for name, template in configs : name => {
      content = templatestring(template.content, local.device_variables[device])
      order   = template.order
    } }
  }

  all_cli_templates = { for device in local.managed_devices :
    device.name => concat(
      [for name, template in local.global_cli_templates[device.name] : { "name" = name, "content" = template.content, "order" = template.order }],
      [for name, template in local.group_cli_templates[device.name] : { "name" = name, "content" = template.content, "order" = template.order }],
      [for name, template in local.device_cli_templates[device.name] : { "name" = name, "content" = template.content, "order" = template.order }],
      try(device.cli_templates, [])
    )
  }

  nxos_devices = {
    nxos = {
      devices = [
        for device in try(local.managed_devices, []) : {
          name    = device.name
          url     = device.url
          managed = try(device.managed, local.defaults.nxos.devices.managed, true)
          configuration = merge(
            { for k, v in try(local.device_config[device.name], {}) : k => v if k != "interfaces" },
            {
              interfaces = merge(
                { for k, v in try(local.device_config[device.name].interfaces, {}) : k => v if !contains(["ethernets", "port_channels", "loopbacks", "vlans"], k) },
                {
                  "ethernets" = [
                    for ethernet in [
                      for eth in try(local.device_config[device.name].interfaces.ethernets, []) : merge(
                        yamldecode(provider::utils::yaml_merge(concat(
                          [for g in try(eth.interface_groups, []) : try([for ig in local.interface_groups_config[device.name] : yamlencode(ig.configuration) if ig.name == g][0], "")],
                          [yamlencode(eth)]
                        )))
                      )
                      ] : merge(
                      { for k, v in ethernet : k => v if k != "subinterfaces" },
                      {
                        subinterfaces = [
                          for sub in try(ethernet.subinterfaces, []) : merge(
                            yamldecode(provider::utils::yaml_merge(concat(
                              [for g in try(sub.interface_groups, []) : try([for ig in local.interface_groups_config[device.name] : yamlencode(ig.configuration) if ig.name == g][0], "")],
                              [yamlencode(sub)]
                            )))
                          )
                        ]
                      }
                    )
                  ]
                },
                {
                  "port_channels" = [
                    for port_channel in [
                      for pc in try(local.device_config[device.name].interfaces.port_channels, []) : merge(
                        yamldecode(provider::utils::yaml_merge(concat(
                          [for g in try(pc.interface_groups, []) : try([for ig in local.interface_groups_config[device.name] : yamlencode(ig.configuration) if ig.name == g][0], "")],
                          [yamlencode(pc)]
                        )))
                      )
                      ] : merge(
                      { for k, v in port_channel : k => v if k != "subinterfaces" },
                      {
                        subinterfaces = [
                          for sub in try(port_channel.subinterfaces, []) : merge(
                            yamldecode(provider::utils::yaml_merge(concat(
                              [for g in try(sub.interface_groups, []) : try([for ig in local.interface_groups_config[device.name] : yamlencode(ig.configuration) if ig.name == g][0], "")],
                              [yamlencode(sub)]
                            )))
                          )
                        ]
                      }
                    )
                  ]
                },
                {
                  "loopbacks" = [
                    for loopback in try(local.device_config[device.name].interfaces.loopbacks, []) : merge(
                      yamldecode(provider::utils::yaml_merge(concat(
                        [for g in try(loopback.interface_groups, []) : try([for ig in local.interface_groups_config[device.name] : yamlencode(ig.configuration) if ig.name == g][0], "")],
                        [yamlencode(loopback)]
                      )))
                    )
                  ]
                },
                {
                  "vlans" = [
                    for vlan in try(local.device_config[device.name].interfaces.vlans, []) : merge(
                      yamldecode(provider::utils::yaml_merge(concat(
                        [for g in try(vlan.interface_groups, []) : try([for ig in local.interface_groups_config[device.name] : yamlencode(ig.configuration) if ig.name == g][0], "")],
                        [yamlencode(vlan)]
                      )))
                    )
                  ]
                }
              )
            }
          )
          cli_templates = local.all_cli_templates[device.name]
        }
      ]
    }
  }
}
