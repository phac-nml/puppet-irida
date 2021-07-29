#Installation of IRIDA web server
class irida(
  String  $tomcat_user          = 'tomcat',
  String  $tomcat_group         = 'tomcat',
  Boolean $manage_user          = true,
  String  $tomcat_tmp           = '/var/cache/tomcat/temp',
  String  $tomcat_location      = '/opt/tomcat/',
  String  $tomcat_logs_location = "${tomcat_location}/logs",
  Integer $java_heap_memory     = 1024,
  String  $irida_ip_addr        = 'localhost',
  String  $server_base_url      = 'localhost',
  String  $irida_version        = '20.01.2', #release tags  https://github.com/phac-nml/irida/releases
  String  $war_url              = "https://github.com/phac-nml/irida/releases/download/${irida_version}/irida-${irida_version}.war",
  String  $irida_url_path       = 'irida',
  String  $linker_script        = 'ngsArchiveLinker.pl',


  Boolean       $splunk_index_logs       = false,
  String        $splunk_receiver         = 'my-splunk-receiver-example.com',
  String        $splunk_index            = '',
  Array[String] $splunk_target_log_files = [
    "${tomcat_logs_location}/catalina.out"
  ],

  Boolean $make_db            = true,
  String  $db_user            = 'irida',
  String  $db_name            = 'irida',
  String  $db_password        = 'irida',
  String  $db_host            = '127.0.0.1',
  String  $db_backup_location = '/tmp/',

  Integer $file_upload_max_size        = 16106127360,
  Integer $file_processing_core        = 4,
  Integer $file_processing_max         = 8,
  Integer $file_process_queue_capacity = 512,

  Boolean $nfs_based           = false,
  String  $data_directory      = '/opt/data',
  String  $sequence_directory  = "${data_directory}/sequence",
  String  $reference_directory = "${data_directory}/reference",
  String  $output_directory    = "${data_directory}/output",
  String  $assembly_directory  = "${data_directory}/assembly",
  String  $profile             = 'prod',

  String $galaxy_execution_url         = 'http://usegalaxy.org',
  String $galaxy_execution_apikey      = 'changemetorealapikey',
  String $galaxy_execution_email       = 'workflow@localhost.com',
  String $galaxy_execution_datastorage = 'local',
  String $irida_disabled_workflow      = '',

  Boolean $use_ssl              = false,
  Boolean $force_ssl            = false,
  String  $ssl_server_cert      = '',
  String  $ssl_chainbundle_cert = '',
  String  $ssl_cert_private_key = '',

  String $mail_server_host       = 'mail.ca',
  String $mail_server_protocol   = 'smtp',
  String $mail_server_email      = 'irida@mail.ca',
  String $mail_server_username   = 'IRIDA Platform',
  String $help_page_title        = '',
  String $help_page_url          = '',
  String $help_contact_email     = '',
  String $irida_analysis_warning = '',

  Integer $galaxy_library_upload_timeout      = 300,
  Integer $galaxy_library_upload_polling_time = 5,
  Integer $galaxy_library_upload_threads      = 1,
  Integer $irida_workflow_max_running         = 4,
  Integer $irida_analysis_cleanup_days        = 15,
  String  $irida_scheduled_subscription_cron  = '0 0 0 * * *',
  Integer $security_password_expiry           = -1,
  Integer $irida_scheduled_threads            = 2,

  String $ncbi_upload_user                                      = 'test',
  String $ncbi_upload_password                                  = 'password',
  String $ncbi_upload_host                                      = 'localhost',
  String $ncbi_upload_basedirectory                             = 'tmp',
  String $ncbi_upload_namespace                                 = 'IRIDA',
  Integer $ncbi_upload_port                                     = 21,
  Integer $ncbi_upload_controlkeepalivetimeoutseconds           = 300,
  Integer $ncbi_upload_controlkeepalivereplytimeoutmilliseconds = 2000,
  Boolean $ncbi_upload_ftp_passive                              = true,

){
  ensure_packages (['epel-release','python3-pip','python3-devel','python-virtualenv'],{'ensure' => 'present'})
  ensure_packages ( [ 'java-11-openjdk'],{'ensure' => 'present',
  require => Package['epel-release']})

  class {'irida::security':
    apache_use_ssl => $irida::use_ssl
  }

  class {'irida::database':
    make_db     => $irida::make_db,
    db_user     => $irida::db_user,
    db_name     => $irida::db_name,
    db_password => $irida::db_password,
    db_host     => $irida::db_host,
  }

  class {'irida::web_server':
    irida_ip_addr        => $irida::irida_ip_addr,
    apache_use_ssl       => $irida::use_ssl,
    apache_force_ssl     => $irida::force_ssl,
    ssl_server_cert      => $irida::ssl_server_cert,
    ssl_chainbundle_cert => $irida::ssl_chainbundle_cert,
    ssl_cert_private_key => $irida::ssl_cert_private_key,
    irida_url_path       => $irida::irida_url_path,
  }

  if $manage_user {
    user { $tomcat_user:
      ensure     => present,
      managehome => true
    }
  }
  else {
    user { $tomcat_user:}
  }


  file {  $tomcat_location:
    ensure  => 'directory',
    owner   => $tomcat_user,
    group   => $tomcat_group,
    require => User[$tomcat_user]
  }

  tomcat::install { $tomcat_location:
    source_url   => 'https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.55/bin/apache-tomcat-8.5.55.tar.gz',
    user         => $tomcat_user,
    group        => $tomcat_group,
    manage_user  => false,
    manage_home  => false,
    manage_group => false,
    require      => File[$tomcat_location]
  }

  include systemd

  file { '/etc/systemd/system/tomcat.service':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('irida/tomcat.service.erb'),
    require => Tomcat::Install[$tomcat_location],
  } -> Class['systemd::systemctl::daemon_reload']

  service { 'tomcat':
    ensure    => 'running',
    subscribe => File['/etc/systemd/system/tomcat.service'],
  }



  tomcat::war { 'irida.war':
    war_source    => $war_url,
    catalina_base => '/opt/tomcat/',
    user          => $tomcat_user,
    group         => $tomcat_group,
    notify        => Service['tomcat'],
    require       => Tomcat::Install[$tomcat_location]
  }


  tomcat::setenv::entry { 'temp':
    param         => 'CATALINA_TMPDIR',
    value         => "'${irida::tomcat_tmp}'",
    catalina_home => $tomcat_location,
    user          => $tomcat_user,
    group         => $tomcat_group,
    require       => Tomcat::Install[$tomcat_location],
    notify        => Service['tomcat'],
  }


  tomcat::setenv::entry { 'java_opts':
    param         => 'JAVA_OPTS',
    value         => "'-Dspring.profiles.active=${profile} -Dirida.db.profile=prod -Xmx${java_heap_memory}m'",
    catalina_home => '/opt/tomcat/',
    user          => $tomcat_user,
    group         => $tomcat_group,
    require       => Tomcat::Install[$tomcat_location],
    notify        => Service['tomcat'],
  }


  file { '/etc/irida':
    ensure  => 'directory',
    require => User[$tomcat_user]
  }


  file { 'irida.conf':
    ensure  => 'present',
    content => template('irida/irida.conf.erb'),
    path    => '/etc/irida/irida.conf',
    require => File['/etc/irida'],
    notify  => Service['tomcat'],
    owner   => $tomcat_user,
    group   => $tomcat_group,
    mode    => '0600',
  }

  file { 'web.conf':
    ensure  => 'present',
    content => template('irida/web.conf.erb'),
    path    => '/etc/irida/web.conf',
    require => File['/etc/irida'],
    notify  => Service['tomcat'],
    owner   => $tomcat_user,
    group   => $tomcat_group,
    mode    => '0600',
  }

  file { '/etc/irida/plugins':
    ensure  => 'directory',
    require => File['/etc/irida'],
  }

  file { '/etc/irida/analytics':
    ensure  => 'directory',
    require => File['/etc/irida'],
  }

  file { 'google-analytics.html':
    ensure  => 'present',
    source  => 'puppet:///modules/irida/google-analytics.html',
    path    => '/etc/irida/analytics/google-analytics.html',
    require => File['/etc/irida/analytics'],
    notify  => Service['tomcat'],
  }

  file { '/etc/irida/irida_upgrade.config':
    ensure  => 'present',
    content => template('irida/irida_upgrade.config.erb'),
    owner   => root,
    group   => root,
    mode    => '0400'
  }

  file { '/etc/my.cnf':
    ensure  => 'present',
    content => template('irida/my.cnf.erb'),
    owner   => root,
    group   => root,
    mode    => '0600'
  }

  if $nfs_based {
    # We do this due to having to create the directories as a user first on the NFS.
    # As the NFS does not allow the root to change permissions due to our security restrictions.
    $irida_directories = [$irida::data_directory,
                          $irida::sequence_directory,
                          $irida::reference_directory,
                          $irida::output_directory,
                          $irida::assembly_directory,
                          $irida::tomcat_tmp]

    $irida_directories.each |String $dir| {
      exec { "mkdir_${dir}":
        command  => "mkdir -p ${dir}",
        provider => 'shell',
        creates  => $dir,
        user     => $irida::tomcat_user,
        require  => [Tomcat::Install[$tomcat_location],Tomcat::War["${irida_url_path}.war"],User[$tomcat_user]],
      }
    }
  }
  else {
    file { 'irida data':
      ensure  => 'directory',
      path    => $irida::data_directory,
      owner   => $tomcat_user,
      group   => $tomcat_group,
      require => [Tomcat::Install[$tomcat_location],Tomcat::War["${irida_url_path}.war"]]
    }

    file { 'irida ref':
      ensure  => 'directory',
      path    => $irida::reference_directory,
      owner   => $tomcat_user,
      group   => $tomcat_group,
      require => File[$irida::data_directory]
    }

    file { 'irida sequence':
      ensure  => 'directory',
      path    => $irida::sequence_directory,
      owner   => $tomcat_user,
      group   => $tomcat_group,
      require => File[$irida::data_directory]
    }

    file { 'irida output':
      ensure  => 'directory',
      path    => $irida::output_directory,
      owner   => $tomcat_user,
      group   => $tomcat_group,
      require => File[$irida::data_directory]
    }

    file { 'irida assembly':
      ensure  => 'directory',
      path    => $irida::assembly_directory,
      owner   => $tomcat_user,
      group   => $tomcat_group,
      require => File[$irida::data_directory]
    }


    file { 'tomcat temp':
      ensure  => 'directory',
      path    => $irida::tomcat_tmp,
      owner   => $tomcat_user,
      group   => $tomcat_group,
      require => Tomcat::Install[$tomcat_location]
    }
  }

  file { [ '/var/cache/tomcat',
    '/var/cache/tomcat/work']:
    ensure  => 'directory',
    owner   => $tomcat_user,
    group   => $tomcat_group,
    require => Tomcat::Install[$tomcat_location]
  }

# Splunk Logging

  if $splunk_index_logs {
    if !defined(Class[::splunk::params]) {
      class {'::splunk::params':
          server => $splunk_receiver,
      }
    }

    if !defined(Class[::splunk::forwarder]) {
      include ::splunk::forwarder
    }

    $splunk_target_log_files.each |String $log_file| {
      @splunkforwarder_input { "monitor_${log_file}":
        section => "monitor://${log_file}",
        setting => 'sourcetype',
        value   => 'irida',
        tag     => 'splunkX_forwarder'
      }
      if !empty($splunk_index) {
        @splunkforwarder_input { "set_index_${log_file}":
          section => "monitor://${log_file}",
          setting => 'index',
          value   => $splunk_index,
          tag     => 'splunk_forwarder'
        }
      }
    }
  }
}
