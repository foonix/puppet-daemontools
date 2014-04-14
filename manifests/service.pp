define daemontools::service(
    $ensure = 'running',
    $program,
    $user = 'root',
    $location = '/service',
    $logaction = false
){
	case $ensure {
		'running': {
			daemontools::service::running { $name:
				program => $program,
				user => $user,
				location => $location,
				logaction => $logaction
			}
			
			file { "${location}/${name}/down":
				ensure => absent
			}
		}
		'present': {
			daemontools::service::running { $name:
				program => $program,
				user => $user,
				location => $location,
				logaction => $logaction
			}
			
			file { "${location}/${name}/down":
				ensure => present
			}
		}
		'absent': {
			file { "${location}/${name}":
				ensure => absent
			}
		}
		default: { fail("unknown ensure value ${ensure} for daemontools::service") }
	}
}

define daemontools::service::running($program, $user, $logaction = false, $location = '/service')
{
	file { "$location/$name":
		ensure => directory,
		owner => root,
		group => root,
		require => Package[daemontools]
	}
	
	file { "$location/$name/supervise":
		ensure => directory,
		owner => root,
		group => root
	}
	
	file { "$location/$name/run":
		content => template("daemontools/main_run.erb"),
		mode => 0755,
		owner => root,
		group => root
	}
	
	if $logaction {
		daemontools::service::running { "${name}/log":
			program => "multilog ${logaction}",
			user => $user,
			location => $location,
			require => File["$location/$name"]
		}
	}
}
