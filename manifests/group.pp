# == Define: Group
#
#
# === Parameters
#
# [*ensure*]
#   The state at which to maintain the group.
#   Can be one of "present" or "absent".
#   Defaults to present.
#
# [*groupname*]
#   The name of the group to be created.
#   Defaults to the title of the account resource.
#
# [*gid*]
#   The GID to set for the new group.
#   If set to undef, this will be auto-generated.
#   Defaults to undef.
#
# [*members*]
#   An array of users to add to the group.
#   Defaults to an empty array.
#
# [*system*]
#   Whether the user is a "system" group or not.
#   Defaults to false.
#
# [*allowdupe*]
#   Whether to allow duplicate UIDs.
#   Defaults to false.
#   Valid values are true, false, yes, no.
#
# === Examples
#
#  group { 'docker':
#    gid   => '999',
#    members => [ 'foo', 'bar' ],
#  }
#
# === Authors
#
# Brad Cowie <brad@wand.net.nz>
#
# === Copyright
#
# Copyright 2016 Brad Cowie, unless otherwise noted
#

define account::group (
  $ensure    = present,
  $groupname = $title,
  $system    = false,
  $gid       = undef,
  $members   = [],
  $allowdupe = false,
) {

  group {
    $title:
      ensure    => $ensure,
      name      => $groupname,
      system    => $system,
      gid       => $gid,
      members   => $members,
      allowdupe => $allowdupe,
  }

}
