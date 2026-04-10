locals {
  user_privilege_type_map = {
    "no-data-priv" = "noDataPriv"
    "read-priv"    = "readPriv"
    "write-priv"   = "writePriv"
  }
}

resource "nxos_user_management" "user_management" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].aaa.users, null) != null ||
    try(local.device_config[device.name].banner, null) != null ||
  try(local.device_config[device.name].aaa.tacacs, null) != null }
  device = each.key

  # Top-level attributes (aaaUserEp) — data model path: users
  alphabet_sequence         = try(local.device_config[each.key].aaa.users.userpassphrase.sequence_alphabet_length, null)
  description               = try(local.device_config[each.key].aaa.users.description, null)
  keyboard_sequence         = try(local.device_config[each.key].aaa.users.userpassphrase.sequence_keyboard_length, null)
  max_logins                = try(local.device_config[each.key].aaa.users.max_logins, null)
  min_unique                = try(local.device_config[each.key].aaa.users.userpassphrase.min_unique, null)
  password_grace_time       = try(local.device_config[each.key].aaa.users.userpassphrase.default_gracetime, null)
  password_life_time        = try(local.device_config[each.key].aaa.users.userpassphrase.default_lifetime, null)
  password_max_length       = try(local.device_config[each.key].aaa.users.userpassphrase.max_length, null)
  password_min_length       = try(local.device_config[each.key].aaa.users.userpassphrase.min_length, null)
  password_secure_mode      = try(local.device_config[each.key].aaa.users.password_secure_mode, null) == null ? null : (try(local.device_config[each.key].aaa.users.password_secure_mode) ? "yes" : "no")
  password_strength_check   = try(local.device_config[each.key].aaa.users.password_strength_check, null) == null ? null : (try(local.device_config[each.key].aaa.users.password_strength_check) ? "yes" : "no")
  password_warning_time     = try(local.device_config[each.key].aaa.users.userpassphrase.default_warntime, null)
  service_password_recovery = try(local.device_config[each.key].aaa.users.service_password_recovery, null) == null ? null : (try(local.device_config[each.key].aaa.users.service_password_recovery) ? "yes" : "no")

  # Pre-login banner (aaaPreLoginBanner) — data model path: banner.motd
  pre_login_banner_message = try(local.device_config[each.key].banner.motd, null)

  # Post-login banner (aaaPostLoginBanner) — data model path: banner.exec
  post_login_banner_message = try(local.device_config[each.key].banner.exec, null)

  # Users (aaaUser) — data model path: users.accounts
  users = { for user in try(local.device_config[each.key].aaa.users.accounts, []) : user.username => {
    account_status           = try(user.account_status, null) == null ? null : (try(user.account_status) ? "active" : "inactive")
    allow_expired            = try(user.allow_expired, null) == null ? null : (try(user.allow_expired) ? "yes" : "no")
    clear_password_history   = try(user.clear_password_history, null) == null ? null : (try(user.clear_password_history) ? "yes" : "no")
    description              = try(user.description, null)
    email                    = try(user.email, null)
    expiration               = try(user.expiration, null)
    expires                  = try(user.expires, null) == null ? null : (try(user.expires) ? "yes" : "no")
    first_name               = try(user.first_name, null)
    force                    = try(user.force, null) == null ? null : (try(user.force) ? "yes" : "no")
    last_name                = try(user.last_name, null)
    password_hash            = try(user.password_hash, null)
    phone                    = try(user.phone, null)
    password                 = try(user.password, null)
    password_encryption_type = try(user.password_encryption_type, null)
    shell_type               = try(user.shell_type, null) == null ? null : (try(user.shell_type) == "bash" ? "shellbash" : "shellvsh")
    unix_user_id             = try(user.unix_user_id, null)

    # User roles (aaaUserRole via aaaUserDomain) — data model path: users.accounts.roles
    roles = { for role in try(user.roles, []) : role.name => {
      description    = try(role.description, null)
      privilege_type = try(local.user_privilege_type_map[try(role.privilege_type)], null)
    } }
  } }

  # TACACS+ (aaaTacacsPlusEp) — data model path: tacacs
  tacacs_deadtime         = try(local.device_config[each.key].aaa.tacacs.deadtime, null)
  tacacs_description      = try(local.device_config[each.key].aaa.tacacs.description, null)
  tacacs_key              = try(local.device_config[each.key].aaa.tacacs.key, null)
  tacacs_key_encryption   = try(local.device_config[each.key].aaa.tacacs.key_encryption, null)
  tacacs_retries          = try(local.device_config[each.key].aaa.tacacs.retries, null)
  tacacs_source_interface = try(local.device_config[each.key].aaa.tacacs.source_interface_type, null) != null ? "${local.intf_prefix_map[try(local.device_config[each.key].aaa.tacacs.source_interface_type)]}${try(local.device_config[each.key].aaa.tacacs.source_interface_id, "")}" : null
  tacacs_timeout          = try(local.device_config[each.key].aaa.tacacs.timeout, null)

  # TACACS+ providers (aaaTacacsPlusProvider) — data model path: tacacs.servers
  tacacs_providers = { for server in try(local.device_config[each.key].aaa.tacacs.servers, []) : server.host => {
    authentication_protocol  = try(server.authentication_protocol, null)
    description              = try(server.description, null)
    key                      = try(server.key, null)
    key_encryption           = try(server.key_encryption, null)
    monitoring_idle_time     = try(server.test_idle_time, null)
    monitoring_password      = try(server.test_password, null)
    monitoring_password_type = try(server.test_password_type, null)
    monitoring_user          = try(server.test_username, null)
    port                     = try(server.port, null)
    retries                  = try(server.retries, null)
    single_connection        = try(server.single_connection, null) == null ? null : (try(server.single_connection) ? "yes" : "no")
    timeout                  = try(server.timeout, null)
  } }

  # TACACS+ provider groups (aaaTacacsPlusProviderGroup) — data model path: tacacs.server_groups
  tacacs_provider_groups = { for group in try(local.device_config[each.key].aaa.tacacs.server_groups, []) : group.name => {
    deadtime         = try(group.deadtime, null)
    description      = try(group.description, null)
    source_interface = try(group.source_interface_type, null) != null ? "${local.intf_prefix_map[try(group.source_interface_type)]}${try(group.source_interface_id, "")}" : null
    vrf              = try(group.vrf, null)
  } }

  depends_on = [
    nxos_feature.feature,
  ]
}
