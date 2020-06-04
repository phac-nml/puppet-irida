# @summary Installation of front end for IRIDA using httpd
#
# Installation of httpd with specific configuration for IRIDA
#
# @example
#   include irida::web_server
class irida::web_server (
  Boolean $apache_use_ssl = false,
  String  $cert_file_path = '',
  String  $cert_key_file_path = '',
  String  $irida_ip_addr = $ipaddress,
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
      ensure => 'present',
      source => $cert_file_path,
      path   => '/etc/ssl/certs/server.crt',
      notify => Service['httpd.service'],

    }

    file { 'server.key':
      ensure => 'present',
      source => $cert_key_file_path,
      path   => '/etc/ssl/certs/server.key',
      notify => Service['httpd.service'],
    }
  }
}
