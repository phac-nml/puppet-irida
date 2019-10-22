#Installation of IRIDA web server
class irida(
  String $tomcat_user = 'tomcat',
  String $tomcat_group = 'tomcat',
  Boolean $manage_user = true,
  String $tomcat_tmp = '/var/cache/tomcat/temp',
  String $irida_ip_addr = $ipaddress,
  String $irida_version='19.09.1', #release tags  https://github.com/phac-nml/irida/releases

  Boolean $make_db = true,
  String  $db_user = 'irida',
  String  $db_name = 'irida',
  String  $db_password = 'irida',
  String  $db_host = '127.0.0.1',

  Integer $file_upload_max_size = 16106127360,
  Integer $file_processing_core = 4,
  Integer $file_processing_max = 8,
  Integer $file_process_queue_capacity = 512,

  String $data_directory = '/opt/data',
  String $sequence_directory = "${data_directory}/sequence",
  String $reference_directory = "${data_directory}/reference",
  String $output_directory = "${data_directory}/output",
  String $profile = 'prod',

  String $galaxy_execution_url= 'http://usegalaxy.org',
  String $galaxy_execution_apikey= 'changemetorealapikey',
  String $galaxy_execution_email='workflow@localhost.com',
  String $galaxy_execution_datastorage='local',
  String $irida_disabled_workflow='',


  String $mail_server_host='mail.ca',
  String $mail_server_protocol='smtp',
  String $mail_server_email='irida@mail.ca',
  String $mail_server_username='IRIDA Platform',
  String $help_page_title='',
  String $help_page_url='',
  String $help_contact_email='',
  String $irida_analysis_warning='',

  Integer $galaxy_library_upload_timeout=300,
  Integer $galaxy_library_upload_polling_time=5,
  Integer $galaxy_library_upload_threads=1,
  Integer $irida_workflow_max_running=4,
  Integer $irida_analysis_cleanup_days=15,
  String  $irida_scheduled_subscription_cron='0 0 0 * * *',
  Integer $security_password_expiry=-1,
  Integer $irida_scheduled_threads=2,


  String $ncbi_upload_user='test',
  String $ncbi_upload_password='password',
  String $ncbi_upload_basedirectory='tmp',
  String $ncbi_upload_namespace='IRIDA',
  Integer $ncbi_upload_port=21,
  Integer $ncbi_upload_controlkeepalivetimeoutseconds=300,
  Integer $ncbi_upload_controlkeepalivereplytimeoutmilliseconds=2000,
  Boolean $ncbi_upload_ftp_passive=true,

){
  ensure_packages (['epel-release'],{'ensure' => 'present'})

  ensure_packages ( [ 'java-1.8.0-openjdk-headless'],{'ensure' => 'present',
  require => Package['epel-release']})

  include irida::security
  include irida::database
  include irida::web_server

  if $manage_user {
    user { $tomcat_user:
      ensure     => present,
      managehome => true
    }
  }
  else {
    user { $tomcat_user:}
  }


  tomcat::install { 'tomcat':
    package_name        => 'tomcat',
    package_ensure      => 'present',
    install_from_source => false,
    user                => $tomcat_user,
    group               => $tomcat_group,
    manage_user         => false,
    require             => User[$tomcat_user]
  }

  tomcat::service {'tomcat.service':
    use_init       => true,
    service_ensure => true,
    service_enable => true,
    service_name   => 'tomcat.service',
    require        => Tomcat::Install['tomcat']
  }

  tomcat::war { 'irida.war':
    war_source    => "https://github.com/phac-nml/irida/releases/download/${irida_version}/irida-${irida_version}.war",
    catalina_base => '/var/lib/tomcat/',
    user          => $tomcat_user,
    group         => $tomcat_group,
    notify        => Service['tomcat.service'],
    require       => Tomcat::Install['tomcat']
  }

  file_line {'tomcat temp directory':

    ensure  => present,
    path    => '/etc/tomcat/tomcat.conf',
    line    => "CATALINA_TMPDIR=\"${irida::tomcat_tmp}\"",
    match   => '^CATALINA_TMPDIR="/var/cache/tomcat/temp',
    require => Tomcat::Install['tomcat'],
    notify  => Service['tomcat.service']
  }

  file_line { 'tomcat java options':
    ensure  => present,
    path    => '/etc/tomcat/tomcat.conf',
    line    => "JAVA_OPTS='-Dspring.profiles.active=${profile} -Dirida.db.profile=prod'",
    require => Tomcat::Install['tomcat'],
    notify  => Service['tomcat.service']
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
    notify  => Service['tomcat.service'],
  }



  file { 'web.conf':
    ensure  => 'present',
    content => template('irida/web.conf.erb'),
    path    => '/etc/irida/web.conf',
    require => File['/etc/irida'],
    notify  => Service['tomcat.service'],
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
    notify  => Service['tomcat.service'],
  }

  exec {'irida directories':
    command  => "mkdir -p ${irida::data_directory};
    mkdir -p ${irida::reference_directory};
    mkdir -p ${irida::sequence_directory};
    mkdir -p ${irida::output_directory};",
    provider => 'shell',
    creates  => $irida::data_directory,
    user     => $irida::tomcat_user,
    require  => [Tomcat::Install['tomcat'],Tomcat::War['irida.war'],User[$tomcat_user]]
  }


  # file { 'irida data':
  #   ensure  => 'directory',
  #   path    => $irida::data_directory,
  #   owner   => $tomcat_user,
  #   group   => $tomcat_group,
  #   require => [Tomcat::Install['tomcat'],Tomcat::War['irida.war']]
  # }

  # file { 'irida ref':
  #   ensure  => 'directory',
  #   path    => $irida::reference_directory,
  #   owner   => $tomcat_user,
  #   group   => $tomcat_group,
  #   require => File[$irida::data_directory]
  # }

  # file { 'irida sequence':
  #   ensure  => 'directory',
  #   path    => $irida::sequence_directory,
  #   owner   => $tomcat_user,
  #   group   => $tomcat_group,
  #   require => File[$irida::data_directory]
  # }

  # file { 'irida output':
  #   ensure  => 'directory',
  #   path    => $irida::output_directory,
  #   owner   => $tomcat_user,
  #   group   => $tomcat_group,
  #   require => File[$irida::data_directory]
  # }


  file { [ '/var/cache/tomcat',
    '/var/lib/tomcat/webapps',
    '/var/cache/tomcat/work',
    $irida::tomcat_tmp ]:
    ensure  => 'directory',
    owner   => $tomcat_user,
    group   => $tomcat_group,
    require => Tomcat::Install['tomcat']
  }



}
