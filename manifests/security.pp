#security for IRIDA instance
class irida::security {


  if $::facts['os']['selinux']['enabled'] {
    include firewalld
    firewalld_port { 'Open port 80 in the public zone':
      ensure   => present,
      zone     => 'public',
      port     => 80,
      protocol => 'tcp',
    }

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
