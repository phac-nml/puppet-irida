#Database management for IRIDA
class irida::database {


  if $irida::make_db {
    ensure_packages ( [ 'mariadb-server'],{'ensure' => 'present',
    require => Package['epel-release']})


    service {'mariadb.service':
      ensure  => running,
      enable  => true,
      require => Package['mariadb-server'],
    }

    mysql::db { 'Create Database':
        user     => $irida::db_user,
        password => $irida::db_password,
        dbname   => $irida::db_name,
        host     => $irida::db_host,
        require  => Service['mariadb.service'],
    }


  }
}
