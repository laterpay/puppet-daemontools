class daemontools (

    $ensure                     = $daemontools::params::ensure,
    $status                     = $daemontools::params::status,
    $package_ensure             = $daemontools::params::package_ensure,
    $package_name               = $daemontools::params::package_name,
    $package_installpath        = $daemontools::params::package_installpath,
    $package_service_dir        = $daemontools::params::service_dir,
    $package_supervise_dir      = $daemontools::params::package_supervise_dir,
    $package_service_name       = $daemontools::params::package_service_name,
    $package_service_ensure     = $daemontools::params::package_service_ensure,
    $package_service_hasstatus  = $daemontools::params::package_service_hasstatus,
    $package_service_hasrestart = $daemontools::params::package_service_hasrestart,
    $package_service_providers  = $daemontools::params::package_service_providers

) inherits daemontools::params {

  # ensure
  if ! ($ensure in [ 'present', 'absent' ]) {
    fail("\"${ensure}\" is not a valid ensure parameter value")
  }
  # service status
  if ! ($status in [ 'enabled', 'disabled', 'running' ]) {
    fail("\"${status}\" is not a valid status parameter value")
  }

  if $ensure == 'absent' or $ensure == 'purged' {
    anchor { 'daemontools::begin': }
    ~> class { 'daemontools::service': }
    -> class { 'daemontools::install': }
    -> anchor { 'daemontools::end': }
  } else {
    anchor { 'daemontools::begin': }
    -> class { 'daemontools::install': }
    ~> class { 'daemontools::service': }
    -> anchor { 'daemontools::end': }
  }
}
