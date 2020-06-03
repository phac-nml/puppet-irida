#security for IRIDA instance
class irida::security(
  Boolean $use_ssl = $use_ssl
){
  include firewalld
  firewalld_port { 'Open port 80 in the public zone':
    ensure   => present,
    zone     => 'public',
    port     => 80,
    protocol => 'tcp',
  }

  if $use_ssl {
    firewalld_port { 'Open port 443 in the public zone':
      ensure   => present,
      zone     => 'public',
      port     => 443,
      protocol => 'tcp',
    }
  }

  if $::facts['os']['selinux']['enabled'] {
    selboolean { 'httpd_can_network_connect':
      persistent => true,
      value      => on,
    }
    selboolean { 'httpd_use_nfs':
      persistent => true,
      value      => on,
    }
    selboolean { 'tomcat_can_network_connect_db':
      persistent => true,
      value      => on,
    }

    file { 'irida.pp':
      ensure => 'file',
      source => 'puppet:///modules/irida/irida_pp',
      path   => '/usr/share/selinux/targeted/irida.pp',
    }

    selmodule { 'set irida policy':
      ensure       => present,
      name         => 'irida',
      selmoduledir => '/usr/share/selinux/targeted',
      require      => File['irida.pp']
    }
  }
}
