define account::ssh_key (
  $ensure = present,
  $user = undef
) {
  $bits = split($title, ' ')

  if size($bits) != 3 {
    fail("malformed ssh key definition, the format I expect: [type] [key] [description]")
  } else {
    $type = $bits[0]
    $key  = $bits[1]
    $desc = $bits[2]

    ssh_authorized_key { "${user}_ssh_key_${desc}":
      ensure => $ensure,
      user   => $user,
      name   => $desc,
      type   => $type,
      key    => $key
    }
  }
}
