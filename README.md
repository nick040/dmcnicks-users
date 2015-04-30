# The users module

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
4. [Usage](#usage)
5. [Limitations](#limitations)
6. [Development](#development)

## Overview

Configures accounts on nodes.

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

    "jbloggs":
      uid: "1000"
      realname: "Joe Bloggs"
      password: "$1$TUeG3hig$RSEvnFFKeAxEcgY6kNY2G1"
      groups: "first"
      sshkeys:
        "jbloggs-1":
          type: "rsa"
          key: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA..."

### SSH keys

The value of the `sshkeys` key is itself a hash that must define two values:

* type - the type of SSH key (rsa or dsa)
* key - the key itself (without a prefixed type or trailing comment)

Every SSH key must have a unique name across all users, because they are
added using the `ssh_authorized_key` defined type and each defined type
declaration must have a unique title. I recommend following the pattern
used in the example above and using `<username>-N` for each key.

Users can have any number of public keys defined: just add them to the
`sshkeys` hash and increment the number.

### The `merge_sshkeys` function

This module defines a custom function called `merge_sshkeys` that produces
a single hash of SSH keys from a hash of users. This can be used to insert
public keys into a shared account. For example:

    $users = hiera_hash('accounts::users')
    $sshkeys = merge_sshkeys($users, "git-")

    $defaults = {
      ensure => 'present',
      user   => 'git'
    }

    create_resources('ssh_authorized_key', $sshkeys, $defaults)

This will gather all of the SSH keys defined for all of the users and add
it to the `authorized_keys` file of the `git` user.

The second argument to the `merge_sshkeys` function is a prefix that is added
to each SSH key name, to keep it unique.

## Usage

### The `accounts` class

The module's primary class. 

#### Parameters

#####`users`

(Required) A hash of users to be created. Each value should itself be a
hash that defines:

* uid - the UID of the user

Optionally, the following values can be defined in each user hash:

* realname - the real name (GECOS field) of the user
* password - an MD5 hashed password.
* groups - an array of secondary group names the user should be added to.
* sshkeys - a hash of SSH keys (see the [SSH keys](#ssh-keys) section above).

## Limitations

There may be incompatibilities with other OS versions, packages and
configurations.

## Development

I am happy to receive pull requests. 
