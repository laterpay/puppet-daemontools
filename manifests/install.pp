class daemontools::install inherits daemontools {

    if $caller_module_name != $module_name {
        fail("Use of private class ${name} by ${caller_module_name}")
    }

    package { 
        $package_name:
            ensure  => $package_ensure,
    }

    file {
        '/etc/init/svscan.conf':
            ensure  => file,
            mode    => '0644',
            owner   => 'root',
            group   => 'root',
            content => template("daemontools/svscan.conf.erb"),
            require => Package[$package_name];
        '/usr/bin/svc':
            ensure  => link,
            target  => "${package_installpath}/bin/svc",
            require => Package[$package_name];
        '/usr/bin/svstat':
            ensure  => link,
            target  => "${package_installpath}/bin/svstat",
            require => Package[$package_name];
    }
}
