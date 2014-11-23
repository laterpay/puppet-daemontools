puppet-daemontools
==================

This module can be used to:
* install daemontools
* setup daemontool services

##  Usage ##

### service setup
```puppet
    daemontools::setup {
        'service_name':
            service_run_script      => template("runscript.erb"),
            service_envvars         => {
                'IP'    => $ipaddress,
                'LANG'  => 'en_US.UTF-8'
            },
    }
```

The daemontools::setup will include daemontools::init. ( which installs the package )

So if you need to override the defaults you can do it using hiera:

daemontools::package_name:                  'daemontools-otherpackage'
daemontools::package_supervise_dir:         '/opt/supervise'
daemontools::package_installpath:           '/opt/daemontools'
