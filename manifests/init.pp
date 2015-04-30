# == Class: users
#
# Creates users and transfers SSH keys.
#
# === Parameters
#
# [*users*]
#   A hash of users to be created.
#
# === Authors
#
# David McNicol <david@mcnicks.org>
#

class accounts ( $users ) {
  create_resources('users::user', $users)
}
