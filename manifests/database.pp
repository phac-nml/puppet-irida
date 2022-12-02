#Database management for IRIDA
class irida::database (
  Boolean $make_db = true,
  String $db_user = 'irida',
  String $db_name = 'irida',
  String $db_password = 'irida',
  String $db_host = '127.0.0.1',
){

  if $make_db {
    ensure_packages(['epel-release'], {'ensure' => 'present'})

    package { 'mariadb-server':
      ensure  => 'present',
      require => Package['epel-release']
    }

    service {'mariadb.service':
      ensure  => running,
      enable  => true,
      require => Package['mariadb-server'],
    }

    mysql::db { 'Create Database':
        user     => $db_user,
        password => $db_password,
        dbname   => $db_name,
        host     => $db_host,
        require  => Service['mariadb.service'],
    }


  }
}
