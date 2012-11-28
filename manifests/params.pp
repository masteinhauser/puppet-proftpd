# == Class: proftpd::param
#
# === Examples
#
#   include corosync::params
#
# === Copyright
#
# Copyright 2012 Myles Steinhauser
#
class proftpd::params {
  case $osfamily {
    'debian': {
      $package = 'proftpd-basic'
    }
    'redhat': {
      $package = 'proftpd'
    }
    $default: { fail("Unsupported platform: ${::osfamily}/${::operatingsystem}") }
  }
}

