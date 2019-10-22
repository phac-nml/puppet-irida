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

The IRIDA module requires [puppetlabs-stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib) version 4.0 or newer, [puppetlabs-tomcat](https://forge.puppet.com/puppetlabs/tomcat) version 3.1 or newer , [puppetlabs-mysql](https://forge.puppet.com/puppetlabs/mysql) version 5.4 or newer and [crayfishx-firewalld](https://forge.puppet.com/crayfishx/firewalld)  version 3.4.0 or newer.

### Beginning with irida

The simplest way to get IRIDA up and running with the IRIDA module is to run without any argument for installation

```puppet
include '::irida'
```


## Usage

Include usage examples for common use cases in the **Usage** section. Show your users how to use your module to solve problems, and be sure to include code examples. Include three to five examples of the most important or common tasks a user can accomplish with your module. Show users how to accomplish more complex tasks that involve different types, classes, and functions working in tandem.

## Reference

This section is deprecated. Instead, add reference information to your code as Puppet Strings comments, and then use Strings to generate a REFERENCE.md in your module. For details on how to add code comments and generate documentation with Strings, see the Puppet Strings [documentation](https://puppet.com/docs/puppet/latest/puppet_strings.html) and [style guide](https://puppet.com/docs/puppet/latest/puppet_strings_style.html)

If you aren't ready to use Strings yet, manually create a REFERENCE.md in the root of your module directory and list out each of your module's classes, defined types, facts, functions, Puppet tasks, task plans, and resource types and providers, along with the parameters for each.

For each element (class, defined type, function, and so on), list:

  * The data type, if applicable.
  * A description of what the element does.
  * Valid values, if the data type doesn't make it obvious.
  * Default value, if any.

For example:

```
### `pet::cat`

#### Parameters

##### `meow`

Enables vocalization in your cat. Valid options: 'string'.

Default: 'medium-loud'.
```

## Limitations

In the Limitations section, list any incompatibilities, known issues, or other warnings.

## Development

In the Development section, tell other users the ground rules for contributing to your project and how they should submit their work.

