# proFTPd Module
class proftpd ( $source = 'proftpd',
  $pid_file = '/var/run/proftpd/proftpd.pid',
  $quota_file = '',
  $quota_engine = 'Off',
  $use_ipv6 = 'Off',
  $default_root = '~',
  $user = 'ftp',
  $group = 'ftp',
  $file_umask = '022',
  $dir_umask = '022',
  $auth_user_file = '/etc/proftpd.users',
  $auth_group_file = '/etc/proftpd.users',
  $create_home = 'Off',
  $server_name = 'FTP Server',
  $ident = 'FTP Server ready.',
  $admin = 'admin@example.com' ) inherits proftpd::params {

  package { $package : ensure => present }

  file{ '/etc/proftpd.conf':
    owner   => root,
    group   => root,
    mode    => '0444',
    content => template("${module_name}/${source}.erb"),
    require => Package[$package],
  }

  file{ "$auth_user_file":
    owner   => root,
    group   => root,
    mode    => '0444',
    source  => [ "puppet:///modules/proftpd/${::hostname}-ftpd.passwd", "puppet:///modules/proftpd/ftpd.passwd" ],
    require => Package[$package],
  }

  service{ 'proftpd':
    ensure      => stopped,
    hasrestart  => false,
    require     => [Package[$package],File['/etc/proftpd.conf']],
    subscribe   => File['/etc/proftpd.conf', "$auth_user_file"],
  }

  if ( $quota_file ) {
    file{ '/etc/ftpquota.limittab':
      owner   => root,
      group   => root,
      mode    => '0444',
      source  => [ "puppet:///modules/${module_name}/${quota_file}-ftpquota.limittab" ],
      require => Package[$package],
      notify  => Service['proftpd'],
    }
  }
}

