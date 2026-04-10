variable "yaml_directories" {
  description = "List of paths to YAML directories."
  type        = list(string)
  default     = []
}

variable "yaml_files" {
  description = "List of paths to YAML files."
  type        = list(string)
  default     = []
}

variable "template_directories" {
  description = "List of paths to directories containing template files."
  type        = list(string)
  default     = []
}

variable "template_files" {
  description = "List of paths to template files."
  type        = list(string)
  default     = []
}

variable "model" {
  description = "As an alternative to YAML files, a native Terraform data structure can be provided as well."
  type        = map(any)
  default     = {}
}

variable "managed_device_groups" {
  description = "List of device group names to be managed. By default all device groups will be managed."
  type        = list(string)
  default     = []
}

variable "managed_devices" {
  description = "List of device names to be managed. By default all devices will be managed."
  type        = list(string)
  default     = []
}

variable "save_config" {
  description = "Write changes to startup-config on all devices."
  type        = bool
  default     = false
}

variable "write_model_file" {
  description = "Write the rendered device model to a single YAML file. Value is a path pointing to the file to be created."
  type        = string
  default     = ""
}
