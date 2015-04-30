# == Type: users::user
#
# Defined type used to create a single user.
#
# === Parameters
#
# [*username*]
#   (Namevar) The username of the user.
#
# [*uid*]
#   (Required) The UID of the user.
#
# [*realname*]
#   (Optional) The full name of the user (defaults to username).
#
# [*password*]
#   (Optional) An encrypted version of the user's password (defaults to
#   '!' - which locks the password. SSH key logins will still work).
#
# [*groups*]
#   (Optional) Additional groups the user belongs to (string or array).
#
# [*sshkeys*]
#   (Optional) Hash of ssh keys to be added to the user's authorized_keys
#   file.
#
# === Authors
#
# David McNicol <david@mcnicks.org>
#

define users::user (
  $uid,
  $username = $title,
  $realname = $title,
  $password = '!',
  $groups = [],
  $sshkeys = []
) {

  # Create the user's group.

  group { $username:
    gid => $uid
  }

  # Create the user.

  user { $username:
    ensure         => 'present',
    uid            => $uid,
    gid            => $username,
    comment        => $realname,
    password       => $password,
    groups         => $groups,
    shell          => '/bin/bash',
    home           => "/home/${username}",
    managehome     => true,
    purge_ssh_keys => true,
    require        => [ Group[$username], Group[$groups] ]
  }

  # Create the user's home directory.

  file { "/home/${username}":
    ensure  => 'directory',
    owner   => $username,
    group   => $username,
    mode    => '0700',
    require => [ User[$username], Group[$username] ]
  }

  # Add SSH keys.

  $sshkey_hash = users_hash_sshkeys($username, $sshkeys)

  file { "/home/${username}/.ssh":
    ensure  => 'directory',
    owner   => $username,
    group   => $username,
    mode    => '0700',
    require => File["/home/${username}"]
  }
  
  $defaults = {
    ensure  => 'present',
    user    => $username,
    require => File["/home/${username}/.ssh"]
  }

  create_resources('ssh_authorized_key', $sshkey_hash, $defaults)

}
