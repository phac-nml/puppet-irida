# IRIDA


#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with irida](#setup)
    * [What irida affects](#what-irida-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with irida](#beginning-with-irida)
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


## Limitations

In the Limitations section, list any incompatibilities, known issues, or other warnings.

## Development

In the Development section, tell other users the ground rules for contributing to your project and how they should submit their work.

