# == Define: User
#
# A defined type for managing user accounts
# Features:
#   * Account creation w/ UID control
#   * Setting the login shell
#   * Group creation w/ GID control (optional)
#   * Home directory creation ( and optionally management via /etc/skel )
#   * Support for system users/groups
#   * SSH key management (optional)
#
# === Parameters
#
# [*ensure*]
#   The state at which to maintain the user account.
#   Can be one of "present" or "absent".
#   Defaults to present.
#
# [*username*]
#   The name of the user to be created.
#   Defaults to the title of the account resource.
#
# [*uid*]
#   The UID to set for the new account.
#   If set to undef, this will be auto-generated.
#   Defaults to undef.
#
# [*password*]
#   The initial password to set for the user.
#   The default is to disable the password.
#
# [*shell*]
#   The user's default login shell.
#   The default is '/bin/bash'
#
# [*manage_home*]
#   Whether the underlying user resource should manage the home directory.
#   This setting only determines whether or not puppet will copy /etc/skel.
#   Regardless of its value, at minimum, a home directory and a $HOME/.ssh
#   directory will be created. Defaults to true.
#
# [*home_dir*]
#   The location of the user's home directory.
#   Defaults to "/home/$title".
#
# [*create_group*]
#   Whether or not a dedicated group should be created for this user.
#   If set, a group with the same name as the user will be created.
#   Otherwise, the user's primary group will be set to "users".
#   Defaults to true.
#
# [*groups*]
#   An array of additional groups to add the user to.
#   Defaults to an empty array.
#
# [*system*]
#   Whether the user is a "system" user or not.
#   Defaults to false.
#
# [*ssh_keys*]
#   A list of ssh keys to add to the authorized keys file.
#
# [*comment*]
#   Sets comment metadata for the user
#
# [*gid*]
#   Sets the primary group of this user, if $create_group = false
#   Defaults to 'users'
#     WARNING: Has no effect if used with $create_group = true
#
# === Examples
#
#  user { 'sysadmin':
#    home_dir => '/opt/home/sysadmin',
#    groups   => [ 'sudo', 'wheel' ],
#    ssh_keys => [
#      'ssh-rsa AABBCCDDEEFFGGHHIIJJKKLLMMNNOOPPQQRRSSTTUUVV== test1@test',
#      'ssh-rsa 12345678910123456789012345678901234567890123== test2@test'
#    ],
#  }
#
# === Authors
#
# Tray Torrance <devwork@warrentorrance.com>
# Brad Cowie <brad@gizmoguy.net.nz>
#
# === Copyright
#
# Copyright 2013 Tray Torrance, unless otherwise noted
#
define account::user (
  $username = $title, $password = '!', $shell = '/bin/bash', $manage_home = true,
  $home_dir = undef, $create_group = true, $system = false, $uid = undef,
  $ssh_keys = [], $groups = [], $ensure = present,
  $comment= "$title Puppet-managed User", $gid = 'users'
) {

  if $home_dir == undef {
      $home_dir_real = "/home/${username}"
  } else {
      $home_dir_real = $home_dir
  }

  if $create_group == true {
    $primary_group = $username

    group {
      $title:
        ensure => $ensure,
        name   => $username,
        system => $system,
        gid    => $uid,
    }

    case $ensure {
      present: {
        Group[$title] -> User[$title]
      }
      absent: {
        User[$title] -> Group[$title]
      }
    }
  }
  else {
    $primary_group = $gid
  }

  if $ssh_keys != [] and $ensure == present {
    $keys_ensure = present
  } else {
    $keys_ensure = absent
  }

  case $ensure {
    present: {
      $dir_ensure  = directory
      $dir_owner   = $username
      $dir_group   = $primary_group
      User[$title] -> File["${title}_home"] -> File["${title}_sshdir"]
    }
    absent: {
      $dir_ensure  = absent
      $dir_owner   = undef
      $dir_group   = undef
      File["${title}_sshdir"] -> File["${title}_home"] -> User[$title]
    }
    default: {
      err( "Invalid value given for ensure: ${ensure}. Must be one of present,absent." )
    }
  }

  user {
    $title:
      ensure     => $ensure,
      name       => $username,
      comment    => $comment,
      uid        => $uid,
      shell      => $shell,
      gid        => $primary_group,
      groups     => $groups,
      home       => $home_dir_real,
      managehome => $manage_home,
      system     => $system,
      notify     => Exec["${title}_set_initial_password"]
  }

  exec {
    "${title}_set_initial_password":
      command => "usermod -p '${password}' ${username}",
      onlyif  => "egrep -q '^${username}:[*!]' /etc/shadow",
      path    => "/usr/sbin:/usr/bin:/sbin:/bin",
      require => User[$title];
  }

  file {
    "${title}_home":
      ensure  => $dir_ensure,
      path    => $home_dir_real,
      owner   => $dir_owner,
      group   => $dir_group,
      mode    => 0750;

    "${title}_sshdir":
      ensure  => $dir_ensure,
      path    => "${home_dir_real}/.ssh",
      owner   => $dir_owner,
      group   => $dir_group,
      mode    => 0700;

    "${title}_sshdir_authorized_keys":
      ensure  => $keys_ensure,
      path    => "${home_dir_real}/.ssh/authorized_keys",
      owner   => $dir_owner,
      group   => $dir_group,
      mode    => 0600,
      require => File["${title}_sshdir"],
      content => template("account/authorized_keys.erb");
  }
}
