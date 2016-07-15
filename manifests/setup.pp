define daemontools::setup (

    $service_run_script,
    $supervise_dir              = undef,
    $service_status             = 'running',
    $service_ensure             = 'running',
    $service_envvars            = {},
    $service_log_enabled        = true,
    $service_run_log_script     = "#!/bin/sh \nexec multilog t ./main \n"

){

    include daemontools

    # service status
    if ! ($service_status in [ 'enabled', 'disabled', 'running' ]) {
        fail("\"${service_status}\" is not a valid status parameter value")
    }
    if $service_ensure != true and $service_ensure != false {
        if ! ($service_ensure in [ 'running','stopped']) {
            fail('service_ensure parameter must be running, stopped, true, or false')
        }
    }

    $supervise_dir_final = $supervise_dir ? {
        undef   => $daemontools::params::supervise_dir,
        default => $supervise_dir,
    }

    #### Service management

    # Notice that $service_ensure == 'running' and $service_status == 'disabled'
    # are contradictory and don't have much sense
    # ($service_ensure will have higher priority then)

    case $service_status {
        # Make sure service can be started via svc, but is not automatically started.
        'enabled': {
            daemontools::setup::supervise {
                $name:
                    supervisedir            => "${supervise_dir_final}/${name}",
                    service_run_script      => $service_run_script,
                    service_envvars         => $service_envvars,
                    log_enabled             => $service_log_enabled,
                    service_run_log_script  => $service_run_log_script;
            }

        }
        # Make sure service is automatically started.
        'running': {
            daemontools::setup::supervise {
                $name:
                    supervisedir            => "${supervise_dir_final}/${name}",
                    service_run_script      => $service_run_script,
                    service_envvars         => $service_envvars,
                    log_enabled             => $service_log_enabled,
                    service_run_log_script  => $service_run_log_script;
            }

        }
        # Do nothing for now.
        'disabled': {}

        default: {
            fail("\"${service_status}\" is an unknown service status value")
        }
    }

    # Determine "down" file presence.
    if $service_ensure == 'running' or $service_status == 'running' {
        $file_down_ensure = absent
    } else {
        $file_down_ensure = present
    }

    file { "${supervise_dir_final}/${name}/down":
        ensure => $file_down_ensure,
        notify => Service[$name];
    }

    service {
        $name:
            ensure   => $service_ensure,
            path     => $supervise_dir_final,
            provider => "daemontools";
    }

}

define daemontools::envfile($value,$servicename) {
    $tmp = inline_template('<%= @name.split("/").last %>')
    file { $name :
        mode    => '0644',
        content => "${value[$tmp]}",
        notify => Service[$servicename];
    }
}

define daemontools::setup::supervise($supervisedir, $service_run_script, $log_enabled, $service_run_log_script, $service_envvars )
{

    file { "${supervisedir}":
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => '1755';
    }->
    file { "${supervisedir}/run":
        ensure  => file,
        mode    => '0755',
        owner   => root,
        group   => root,
        content => $service_run_script,
    }->
    file { "${supervisedir}/envdir":
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '1755',
    }

    $envnames = keys($service_envvars)
    $prefixedenvnames = prefix($envnames, "${supervisedir}/envdir/")
    daemontools::envfile { $prefixedenvnames:
        value       => $service_envvars,
        servicename => $name,
        require     => File["${supervisedir}/envdir/"]
    }


    if $log_enabled {
        file {
            "${supervisedir}/log":
                ensure  => directory,
                owner   => 'root',
                group   => 'root',
                mode    => '1755',
                require => File[$supervisedir];
        }->
        file {
            "${supervisedir}/log/run":
                ensure  => file,
                owner   => 'root',
                group   => 'root',
                mode    => '0755',
                content => $service_run_log_script,
        }
    }

    file{
        "/${supervisedir}/check_service":
            ensure  => file,
            owner   => 'root',
            group   => 'root',
            mode    => '0755',
            source  => 'puppet:///modules/laterpay/check_service',
            require => File[$supervisedir];
    }

}

