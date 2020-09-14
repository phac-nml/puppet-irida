# @summary Installation of front end for IRIDA using httpd
#
# Installation of httpd with specific configuration for IRIDA
#
# @example
#   include irida::web_server
class irida::web_server (
  Boolean $apache_use_ssl = false,
  Boolean $apache_force_ssl = false,
  String  $ssl_server_cert = '',
  String  $ssl_chainbundle_cert = '',
  String  $ssl_cert_private_key = '',
  String  $irida_ip_addr = $ipaddress,
  String  $irida_url_path = 'irida',
) {

  ensure_resource('package', 'epel-release', {'ensure' => 'present'})

  package { 'mod_ssl':
    ensure => 'present'
  }

  package { 'httpd':
    ensure  => 'present',
    require => Package['epel-release']
  }

  service { 'httpd.service':
    ensure  => running,
    enable  => true,
    require => [Package['httpd'], File['httpd_irida.conf']]
  }

  file { 'httpd_irida.conf':
    ensure  => 'present',
    content => template('irida/ngs.conf.erb'),
    path    => '/etc/httpd/conf.d/ngs.conf',
    require => Package['httpd'],
    notify  => Service['httpd.service'],
  }

  if $apache_use_ssl {
    file { 'server.crt':
      ensure  => 'present',
      content => template('irida/server.crt.erb'),
      path    => '/etc/ssl/certs/server.crt',
      notify  => Service['httpd.service'],
    }

    file { 'chainbundle.crt':
      ensure  => 'present',
      content => template('irida/chainbundle.crt.erb'),
      path    => '/etc/ssl/certs/chainbundle.crt',
      notify  => Service['httpd.service'],
    }

    file { 'server.key':
      ensure  => 'present',
      content => template('irida/server.key.erb'),
      path    => '/etc/ssl/certs/server.key',
      notify  => Service['httpd.service'],
    }
  }
}
