locals {
  yaml_strings_directories = flatten([
    for dir in var.yaml_directories : [
      for file in fileset(".", "${dir}/**/*.{yml,yaml}") : file(file)
    ]
  ])
  yaml_strings_files = [
    for file in var.yaml_files : file(file)
  ]
  model_strings   = length(keys(var.model)) != 0 ? [provider::utils::yaml_encode(var.model)] : []
  model_string    = provider::utils::yaml_merge(concat(local.yaml_strings_directories, local.yaml_strings_files, local.model_strings))
  model           = provider::utils::yaml_decode(local.model_string)
  user_defaults   = { "defaults" : try(local.model["defaults"], {}) }
  defaults_string = provider::utils::yaml_merge([file("${path.module}/../../defaults/defaults.yaml"), provider::utils::yaml_encode(local.user_defaults)])
  defaults        = provider::utils::yaml_decode(local.defaults_string)["defaults"]
}

resource "local_sensitive_file" "model" {
  count    = var.write_model_file != "" ? 1 : 0
  content  = provider::utils::yaml_encode(local.nxos_devices)
  filename = var.write_model_file
}

resource "local_sensitive_file" "defaults" {
  count    = var.write_default_values_file != "" ? 1 : 0
  content  = local.defaults_string
  filename = var.write_default_values_file
}
