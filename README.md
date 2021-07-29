# IRIDA


#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with irida](#setup)
    * [What irida affects](#what-irida-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with irida](#beginning-with-irida)
    * [Upgrading irida](#upgrading-irida)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

The IRIDA module lets you use Puppet to install, deploy, and configure IRIDA web server (Alpha status)

## Setup

### Setup Requirements

The IRIDA module requires [puppetlabs-stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib) version 4.0 or newer, [puppetlabs-tomcat](https://forge.puppet.com/puppetlabs/tomcat) version 3.1 or newer , [puppetlabs-mysql](https://forge.puppet.com/puppetlabs/mysql) version 5.4 or newer and [puppet-firewalld](https://forge.puppet.com/puppet/firewalld)  version 4.3.0 or newer.

### Beginning with irida

The simplest way to get IRIDA up and running with the IRIDA module is to run without any argument for installation

```puppet
include '::irida'
```

### Upgrading irida

> **[Puppet Bolt](https://puppet.com/docs/bolt/latest/bolt.html) is required to
> use the upgrade task.**

The `upgrade` task included in this module can be used to upgrade the IRIDA
instance to a newer version. This task accepts no parameters and instead
relies on the file managed by the module located at `/etc/irida/irida_upgrade.config`
on the target host, allowing for the upgrade process to automatically retrieve
credentials and other information that it requires.

In order to perform a system upgrade using the `upgrade` task and Puppet Bolt:

1. Apply the IRIDA module with the `irida_version` parameter set to the version
   of IRIDA that you wish to upgrade to. See available version numbers on the
   [IRIDA download page](https://github.com/phac-nml/irida/releases/).
2. Run the upgrade task using Puppet Bolt:  
   `bolt task run -i <inventory file>  -t <target host> irida::upgrade`

The upgrade task performs the following actions:

1. Stop the `puppet` and `tomcat` services
2. Dump the database to a backup file located at `/tmp/irida-<date>.dbbackup` by default 
3. Delete the old `irida.war` file and replaces it with the version specified
4. Start the `puppet` services

## Limitations

In the Limitations section, list any incompatibilities, known issues, or other warnings.

## Development

In the Development section, tell other users the ground rules for contributing to your project and how they should submit their work.

