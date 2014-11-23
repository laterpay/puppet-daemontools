class daemontools::params {

  $ensure = 'present'

  $status = 'enabled'
   
  #### Internal module values

  # Different path definitions
  case $::kernel {
    'Linux': {
      $package_supervise_dir = '/var/lib/svscan'
      $package_service_dir   = '/service'
      $package_installpath   = '/bin'
    }
    default: {
      fail("\"${module_name}\" provides no config directory default value
           for \"${::kernel}\"")
    }
  }

  # packages
  case $::operatingsystem {
    'RedHat', 'CentOS', 'Fedora', 'Scientific', 'Amazon', 'OracleLinux', 'SLC': {
      # main application
      $package_name = [ 'daemontools' ]
    }
    default: {
      fail("\"${module_name}\" provides no package default value
            for \"${::operatingsystem}\"")
    }
  }

  # service parameters
  case $::operatingsystem {
    'RedHat', 'CentOS', 'Fedora', 'Scientific', 'Amazon', 'OracleLinux', 'SLC': {
      $package_service_name = 'svscan'
      $package_service_hasrestart = true
      $package_service_hasstatus  = true
    }
    default: {
      fail("\"${module_name}\" provides no service parameters
            for \"${::operatingsystem}\"")
    }
  }

}
