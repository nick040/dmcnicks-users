# The users module

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
4. [Usage](#usage)
5. [Limitations](#limitations)
6. [Development](#development)

## Overview

Configures local users on nodes.

## Module Description

This Puppet module creates users and manages SSH public keys.

### Tested on

* Debian 7 (wheezy)

## Setup

### What the accounts module affects

* Creates linux users on nodes.
* Adds SSH public keys to user authorized_keys files.

### Beginning with the accounts module

The accounts module expects to be given a hash of users when it is declared
in a manifest. Each user can be declared in Hiera like so:

    jbloggs:
      uid: 1000

A hashed password can be specified:

    jbloggs:
      uid: 1000
      password: $1$TUeG3hig$RSEvnFFKeAxEcgY6kNY2G1

A real name can be specified:

    jbloggs:
      uid: 1000
      password: $1$TUeG3hig$RSEvnFFKeAxEcgY6kNY2G1
      realname: Joe Bloggs

Each new user will be given a primary group named after their username, with
a GID matching the user's UID. An array of supplementary groups can also be
specified (note that the groups have to be created elsewhere):

    jbloggs:
      uid: 1000
      password: $1$TUeG3hig$RSEvnFFKeAxEcgY6kNY2G1
      realname: Joe Bloggs
      groups:
        - admins
        - webdevs

Finally, a number of SSH public keys can be specified. The public keys will
be added to the user's authorized_keys file:

    jbloggs:
      uid: 1000
      password: $1$TUeG3hig$RSEvnFFKeAxEcgY6kNY2G1
      realname: Joe Bloggs
      groups:
        - admins
        - webdevs
      sshkeys:
        - ssh-rsa AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA...AAA user@host
        - ssh-dsa BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB...BBB user@host

### Custom functions

This module defines a number custom function functions that can be used to
manipulate user data and ssh keys.

#### `users_merge_sshkeys`

The `users_merge_sshkeys` function produces a single hash of SSH keys from a hash of users that is properly structured for use with the `ssh_authorized_key`
built-in function.

The first argument to the `users_merge_sshkeys` function is a prefix that is
added to each SSH key name to keep each declared `ssh_authorized_key` resource
unique.

This can be used to insert public keys into a shared account. For example:

    $users = hiera_hash('accounts::users')
    $sshkeys = users_merge_sshkeys('git', $users)

    $defaults = {
      ensure => 'present',
      user   => 'git'
    }

    create_resources('ssh_authorized_key', $sshkeys, $defaults)

#### `users_hash_sshkeys`

The `users_hash_sshkeys` function produces a hash of SSH keys that is properly structured for use with the `ssh_authorized_key` from an array of SSH keys.

The first argument to the `users_merge_sshkeys` function is the name of the
users that the SSH keys will be added to, which ensures that each declared
`ssh_authorized_key` resource will be unique.

This can be used to insert deploy keys into a shared account. For example:

    $deploykeys = [
      "ssh-rsa AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA...AAA user1@host1",
      "ssh-dss BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB...BBB user2@host2"
    ]

    $sshkeys = users_hash_sshkeys('git', $deploykeys)

    $defaults = {
      ensure => 'present',
      user   => 'git'
    }

    create_resources('ssh_authorized_key', $sshkeys, $defaults)

The difference between the `users_hash_sshkeys` and `users_merge_sshkeys`
function is that `users_hash_sshkeys` expects a simple array of strings
containing SSH keys. 

#### `users_filter_by_group`

The `users_hash_sshkeys` function pulls SSH keys from all defined users
but what if you only want some of those users to be given access to a
particular account? The `users_filter_by_group` function can be used before
the `users_hash_sshkeys` function to filter only users that belong to
certain groups. For example:

    $users = hiera_hash('accounts::users')
    $sshkeys = users_merge_sshkeys('git', $users)

    $admins = users_filter_by_group($users, 'admin')
    $devs = users_filter_by_group($users, [ 'wp', 'rails', 'lamp' ])

These filtered hashes of users can then be used just like the hash of all
users:

    $adminkeys = users_merge_sshkeys('git_admins', $admins)

    $defaults = {
      ensure => 'present',
      user   => 'git'
    }

    create_resources('ssh_authorized_key', $adminkeys, $defaults)

## Usage

### The `users` class

The module's primary class. 

#### Parameters

#####`users`

(Required) A hash of users to be created. Each key should be a username and
each value should be a hash that defines at least:

* uid - the UID of the user

And optionally the following:

* realname - the real name (GECOS field) of the user
* password - an MD5 hashed password.
* groups - an array of secondary groups that the user should be added to.
* sshkeys - an array of SSH public keys.

## Limitations

There may be incompatibilities with other OS versions, packages and
configurations.

## Development

I am happy to receive pull requests. 
