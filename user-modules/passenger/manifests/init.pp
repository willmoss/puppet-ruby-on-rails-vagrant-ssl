class passenger {
	exec {
		"/usr/local/bin/gem install passenger -v4.0.2 --no-ri --no-rdoc":
		  user    => root,
		  group   => root,
		  alias   => "install_passenger",
      require => Package["apache2"],
		  unless  => "ls /usr/local/lib/ruby/gems/1.9.1/gems/passenger-4.0.2/"
	}
	exec {
		"/usr/local/bin/passenger-install-apache2-module --auto":
		  user    => root,
		  group   => root,
		  path    => "/bin:/usr/bin:/usr/local/apache2/bin/",
		  alias   => "passenger_apache_module",
		  require => Exec["install_passenger"],
		  unless  => "ls /usr/local/lib/ruby/gems/1.9.1/gems/passenger-4.0.2/libout/apache2/mod_passenger.so"
	}

	package {
    "libcurl4-openssl-dev" :
      ensure => present,
      before => Exec["install_passenger"]
  }

	package {
	  "apache2-prefork-dev":
	    ensure => present,
	    before => Exec["install_passenger"],
	}

	package {
	  "libapr1-dev":
	    ensure => present,
	    before => Exec["install_passenger"]
	}

	package {
	  "libaprutil1-dev":
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
		  source  => "puppet:///modules/passenger/passenger.conf",
		  require => Exec["passenger_apache_module"],
	}
}
