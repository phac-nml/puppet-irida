# @summary Installation of front end for IRIDA using httpd
#
# Installation of httpd with specific configuration for IRIDA
#
# @example
#   include irida::web_server
class irida::web_server (
  String $irida_ip_addr = $ipaddress
) {
  ensure_resource('package', 'epel-release', {'ensure' => 'present'})

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

  service {'httpd.service':
    ensure  => running,
    enable  => true,
    require => Package['httpd']
  }

}
