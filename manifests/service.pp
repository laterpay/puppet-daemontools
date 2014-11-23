class daemontools::service inherits daemontools {

    if $caller_module_name != $module_name {
        fail("Use of private class ${name} by ${caller_module_name}")
    }

    # action
    service {
        $package_service_name:
            ensure      => $package_service_ensure,
            enable      => $package_service_enable,
            hasstatus   => $package_service_hasstatus,
            hasrestart  => $package_service_hasrestart,
            start      => "/sbin/initctl start  ${package_service_name}",
            stop       => "/sbin/initctl stop   ${package_service_name}",
            status     => "/sbin/initctl status ${package_service_name} | grep '/running' 1>/dev/null 2>&1",
    }

    exec {
        'ensure-daemontools-start':
            command => "${package_installpath}/bin/svscanboot &",
            unless  => "ps ax | grep -v grep | grep -q ${package_service_name}",
    }
}
