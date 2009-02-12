define daemontools::service(
    $ensure = 'running',
    $program,
    $user = 'root',
    $logaction = false
){
	case $ensure {
		'running': {
			daemontools::service::running { $name:
				program => $program,
				user => $user,
				logaction => $logaction
			}
			
			file { "/service/${name}/down":
				ensure => absent
			}
		}
		'present': {
			daemontools::service::running { $name:
				program => $program,
				user => $user,
				logaction => $logaction
			}
			
			file { "/service/${name}/down":
				ensure => present
			}
		}
		'absent': {
			file { "/service/${name}":
				ensure => absent
			}
		}
		default: { fail("unknown ensure value ${ensure} for daemontools::service") }
	}
}

define daemontools::service::running($program, $user, $logaction = false)
{
	file { "/service/$name":
		ensure => directory,
		owner => root,
		group => root,
		require => Package[daemontools]
	}
	
	file { "/service/$name/supervise":
		ensure => directory,
		owner => root,
		group => root
	}
	
	file { "/service/$name/run":
		content => template("daemontools/main_run.erb"),
		mode => 0755,
		owner => root,
		group => root
	}
	
	if $logaction {
		daemontools::service::running { "${name}/log":
			program => "/usr/bin/multilog ${logaction}",
			user => $user,
			require => File["/service/$name"]
		}
	}
}
