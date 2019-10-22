#web server
class irida::web_server {


  ensure_packages ( 'httpd',{'ensure' => 'present',
  require => Package['epel-release']})

  $irida_ip_addr = $irida::irida_ip_addr
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
