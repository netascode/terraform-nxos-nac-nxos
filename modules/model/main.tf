locals {
  nxos             = try(local.model.nxos, {})
  global           = try(local.nxos.global, [])
  devices          = try(local.nxos.devices, [])
  device_groups    = try(local.nxos.device_groups, [])
  interface_groups = try(local.nxos.interface_groups, [])

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
      [{ GLOBAL = local.nxos }],
      [try(local.global.variables, {})],
      [for dg in local.device_groups : try(dg.variables, {}) if contains(try(device.device_groups, []), dg.name) || contains(try(dg.devices, []), device.name)],
      [try(device.variables, {})]
    )...)
  }

  templates = { for template in try(local.nxos.templates, []) : template.name => template }

  # File templates — decoded to native values
  global_file_templates = { for device in local.managed_devices :
    device.name => [
      for t in try(local.global.templates, []) :
      provider::utils::yaml_decode(templatefile(local.templates[t].file, local.device_variables[device.name]))
      if try(local.templates[t].type, null) == "file"
    ]
  }

  group_file_templates = { for device in local.managed_devices :
    device.name => flatten([
      for dg in local.device_groups : [
        for t in try(dg.templates, []) :
        provider::utils::yaml_decode(templatefile(local.templates[t].file, merge(local.device_variables[device.name], try(dg.variables, {}))))
        if try(local.templates[t].type, null) == "file"
      ]
      if contains(try(device.device_groups, []), dg.name) || contains(try(dg.devices, []), device.name)
    ])
  }

  device_file_templates = { for device in local.managed_devices :
    device.name => [
      for t in try(device.templates, []) :
      provider::utils::yaml_decode(templatefile(local.templates[t].file, local.device_variables[device.name]))
      if try(local.templates[t].type, null) == "file"
    ]
  }

  # Model templates — encode, render vars, decode, then deep merge natively
  global_model_templates_encoded = { for device in local.managed_devices :
    device.name => [
      for t in try(local.global.templates, []) :
      provider::utils::yaml_encode(try(local.templates[t].configuration, {}))
      if try(local.templates[t].type, null) == "model"
    ]
  }

  global_model_templates = { for device in local.managed_devices :
    device.name => provider::utils::merge([
      for encoded in local.global_model_templates_encoded[device.name] :
      provider::utils::yaml_decode(templatestring(encoded, local.device_variables[device.name]))
    ])
  }

  group_model_templates_encoded = { for device in local.managed_devices :
    device.name => flatten([
      for dg in local.device_groups : [
        for t in try(dg.templates, []) :
        { encoded = provider::utils::yaml_encode(try(local.templates[t].configuration, {})), vars = merge(local.device_variables[device.name], try(dg.variables, {})) }
        if try(local.templates[t].type, null) == "model"
      ]
      if contains(try(device.device_groups, []), dg.name) || contains(try(dg.devices, []), device.name)
    ])
  }

  group_model_templates = { for device in local.managed_devices :
    device.name => provider::utils::merge([
      for item in local.group_model_templates_encoded[device.name] :
      provider::utils::yaml_decode(templatestring(item.encoded, item.vars))
    ])
  }

  device_model_templates_encoded = { for device in local.managed_devices :
    device.name => [
      for t in try(device.templates, []) :
      provider::utils::yaml_encode(try(local.templates[t].configuration, {}))
      if try(local.templates[t].type, null) == "model"
    ]
  }

  device_model_templates = { for device in local.managed_devices :
    device.name => provider::utils::merge([
      for encoded in local.device_model_templates_encoded[device.name] :
      provider::utils::yaml_decode(templatestring(encoded, local.device_variables[device.name]))
    ])
  }

  # 9-level precedence cascade — native deep merge, then templatestring for final variable substitution
  devices_config_encoded = { for device in local.managed_devices :
    device.name => provider::utils::yaml_encode(
      provider::utils::merge(concat(
        local.global_file_templates[device.name],
        [local.global_model_templates[device.name]],
        [try(local.global.configuration, {})],
        local.group_file_templates[device.name],
        [local.group_model_templates[device.name]],
        [for dg in local.device_groups : try(dg.configuration, {}) if contains(try(device.device_groups, []), dg.name) || contains(try(dg.devices, []), device.name)],
        local.device_file_templates[device.name],
        [local.device_model_templates[device.name]],
        [try(device.configuration, {})]
      ))
    )
  }

  devices_config = { for device in local.managed_devices :
    device.name => provider::utils::yaml_decode(templatestring(local.devices_config_encoded[device.name], local.device_variables[device.name]))
  }

  # Interface groups — encode, render vars, decode
  interface_groups_encoded = {
    for device in local.managed_devices : device.name => [
      for ig in local.interface_groups : {
        name    = ig.name
        encoded = provider::utils::yaml_encode(try(ig.configuration, {}))
      }
    ]
  }

  interface_groups_config = {
    for device in local.managed_devices : device.name => [
      for ig in local.interface_groups_encoded[device.name] : {
        name          = ig.name
        configuration = provider::utils::yaml_decode(templatestring(ig.encoded, local.device_variables[device.name]))
      }
    ]
  }

  # CLI templates
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

  # Final output — interface groups merged into device interfaces using native deep merge
  nxos_devices = {
    nxos = {
      devices = [
        for device in try(local.managed_devices, []) : {
          name    = device.name
          url     = device.url
          managed = try(device.managed, local.defaults.nxos.devices.managed, true)
          configuration = merge(
            { for k, v in try(local.devices_config[device.name], {}) : k => v if k != "interfaces" },
            {
              interfaces = merge(
                { for k, v in try(local.devices_config[device.name].interfaces, {}) : k => v if !contains(["ethernets", "port_channels", "loopbacks", "vlans"], k) },
                {
                  "ethernets" = [
                    for ethernet in [
                      for eth in try(local.devices_config[device.name].interfaces.ethernets, []) :
                      provider::utils::merge(concat(
                        [for g in try(eth.interface_groups, []) : try([for ig in local.interface_groups_config[device.name] : ig.configuration if ig.name == g][0], {})],
                        [eth]
                      ))
                      ] : merge(
                      { for k, v in ethernet : k => v if k != "subinterfaces" },
                      {
                        subinterfaces = [
                          for sub in try(ethernet.subinterfaces, []) :
                          provider::utils::merge(concat(
                            [for g in try(sub.interface_groups, []) : try([for ig in local.interface_groups_config[device.name] : ig.configuration if ig.name == g][0], {})],
                            [sub]
                          ))
                        ]
                      }
                    )
                  ]
                },
                {
                  "port_channels" = [
                    for port_channel in [
                      for pc in try(local.devices_config[device.name].interfaces.port_channels, []) :
                      provider::utils::merge(concat(
                        [for g in try(pc.interface_groups, []) : try([for ig in local.interface_groups_config[device.name] : ig.configuration if ig.name == g][0], {})],
                        [pc]
                      ))
                      ] : merge(
                      { for k, v in port_channel : k => v if k != "subinterfaces" },
                      {
                        subinterfaces = [
                          for sub in try(port_channel.subinterfaces, []) :
                          provider::utils::merge(concat(
                            [for g in try(sub.interface_groups, []) : try([for ig in local.interface_groups_config[device.name] : ig.configuration if ig.name == g][0], {})],
                            [sub]
                          ))
                        ]
                      }
                    )
                  ]
                },
                {
                  "loopbacks" = [
                    for loopback in try(local.devices_config[device.name].interfaces.loopbacks, []) :
                    provider::utils::merge(concat(
                      [for g in try(loopback.interface_groups, []) : try([for ig in local.interface_groups_config[device.name] : ig.configuration if ig.name == g][0], {})],
                      [loopback]
                    ))
                  ]
                },
                {
                  "vlans" = [
                    for vlan in try(local.devices_config[device.name].interfaces.vlans, []) :
                    provider::utils::merge(concat(
                      [for g in try(vlan.interface_groups, []) : try([for ig in local.interface_groups_config[device.name] : ig.configuration if ig.name == g][0], {})],
                      [vlan]
                    ))
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
