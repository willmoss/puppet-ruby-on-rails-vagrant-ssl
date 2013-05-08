class advance2 {
	file {
		["/var/advance2/", 
		"/var/advance2/shared/",
		"/var/advance2/shared/config/"]:
		  ensure => directory,
		  owner  => vagrant,
		  group  => vagrant,
		  mode   => 775
	}
	file {
		"/var/advance2/shared/config/database.yml":
		  ensure => present,
		  owner  => vagrant,
		  group  => vagrant,
		  mode   => 600,
		  source => "puppet:///modules/advance2/database.yml"
	}
	package {
		"bundler":
		  provider => gem
	}
}
