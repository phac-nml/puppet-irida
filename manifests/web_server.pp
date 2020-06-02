# @summary Installation of front end for IRIDA using httpd
#
# Installation of httpd with specific configuration for IRIDA
#
# @example
#   include irida::web_server
class irida::web_server (
  String  $irida_ip_addr        = $ipaddress,
  Boolean $use_ssl              = $use_ssl,
  String  $cert_file_path       = $cert_file_path,
  String  $cert_key_file_path   = $cert_key_file_path,
) {

  package { 'mod_ssl':
    ensure => 'present'
  }

  package { 'httpd':
    ensure  => 'present',
    require => Package['epel-release']
  }

  file { 'httpd_irida.conf':
    ensure  => 'present',
    content => template('irida/ngs.conf.erb'),
    path    => '/etc/httpd/conf.d/ngs.conf',
    require => Package['httpd'],
    notify  => Service['httpd.service'],
  }

  if $use_ssl {
    file { 'server.crt':
      ensure => 'present',
      source => $cert_file_path,
      path   => '/etc/ssl/certs/server.crt'
    }

    file { 'server.key':
      ensure => 'present',
      source => $cert_key_file_path,
      path   => '/etc/ssl/certs/server.key'
    }

    exec { 'Start_SSL':
      path    => ['/usr/bin', '/usr/sbin', '/bin'],
      command => 'apachectl restart',
      require => [File['server.crt'], File['server.key']]
    }
  }

  case $use_ssl {
    true: {
      $service_deps = [
                        Package['httpd'],
                        File['httpd_irida.conf'],
                        File['server.crt'],
                        File['server.key'],
                        Exec['Start_SSL']
                      ]
    }
    default: {
      $service_deps = [
                        Package['httpd'],
                        File['httpd_irida.conf']
                      ]
    }
  }

  service {'httpd.service':
    ensure  => running,
    enable  => true,
    require => $service_deps
  }
}
