# proFTPd Module
class proftpd ( $source = 'proftpd',
  $quota_file = '',
  $quota_engine = 'Off',
  $use_ipv6 = 'Off',
  $default_root = '~',
  $user = 'proftpd',
  $group = 'nogroup',
  $file_umask = '022',
  $dir_umask = '022',
  $auth_user_file = '/etc/proftpd.users',
  $auth_group_file = '/etc/proftpd.users',
  $create_home = 'Off',
  $name = 'FTP Server',
  $ident = 'FTP Server ready.',
  $admin = 'admin@example.com' ) inherits proftpd::params {

  package { $package : ensure => present }
  motd::register{'proftpd':}

  file{ '/etc/proftpd/proftpd.conf':
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
    ensure      => running,
    hasrestart  => true,
    require     => [Package[$package],File['/etc/proftpd/proftpd.conf']],
    subscribe   => File['/etc/proftpd/proftpd.conf', "$auth_user_file"],
  }

  if ( $quota_file ) {
		
    file{ '/etc/proftpd/ftpquota.limittab':
      owner   => root,
      group   => root,
      mode    => '0444',
      source  => [ "puppet:///modules/${module_name}/${quota_file}-ftpquota.limittab" ],
      require => Package[$package],
      notify  => Service['proftpd'],
    }
  }
}

