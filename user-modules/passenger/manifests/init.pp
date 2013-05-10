class passenger {
	exec {
		"/usr/local/bin/gem install passenger -v=3.0.11 --no-ri --no-rdoc":
		  user    => root,
	  	  group   => root,
		  alias   => "install_passenger",
                  require => Package["apache2"],
		  before  => [File["passenger_conf"],Exec["passenger_apache_module"]],
		  unless  => "ls /usr/local/lib/ruby/gems/1.9.1/gems/passenger-3.0.11/"
	}
	exec {
		"/usr/local/bin/passenger-install-apache2-module --auto":
		  user    => root,
		  group   => root,
		  path    => "/bin:/usr/bin:/usr/local/apache2/bin/",
		  alias   => "passenger_apache_module",
		  before  => File["passenger_conf"],
		  unless  => "ls /usr/local/lib/ruby/gems/1.9.1/gems/passenger-3.0.11/ext/apache2/mod_passenger.so"
	}
        package {
          "libcurl4-openssl-dev" :
            ensure => present,
            before => Exec["install_passenger"]
        }

	file {
		"/etc/apache2/conf.d/passenger.conf":
		  mode    => 644,
		  owner   => root,
		  group   => root,
		  alias   => "passenger_conf",
		  notify  => Service["apache2"],
		  source  => "puppet:///modules/passenger/passenger.conf"
	}
}
