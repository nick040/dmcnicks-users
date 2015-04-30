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

### The `merge_sshkeys_for` function

This module defines a custom function called `merge_sshkeys_for` that produces
a single hash of SSH keys from a hash of users. This can be used to insert
public keys into a shared account. For example:

    $users = hiera_hash('accounts::users')
    $sshkeys = merge_sshkeys_for('git', $users)

    $defaults = {
      ensure => 'present',
      user   => 'git'
    }

    create_resources('ssh_authorized_key', $sshkeys, $defaults)

This will gather all of the SSH keys defined for all of the users and add
all of them to the `authorized_keys` file of the `git` user.

The first argument to the `merge_sshkeys_for` function is a prefix that is
added to each SSH key name to keep each declared `ssh_authorized_key` resource
unique.

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
