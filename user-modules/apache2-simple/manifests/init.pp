class apache2 {

	apache::vhost { 'localhost':
	    priority        => '10',
	    vhost_name      => 'localhost',
	    port            => '80',
	    docroot         => '/var/www/',
	    logroot         => '/var/www/',
	    serveradmin     => 'webmaster@example.com',
	    serveraliases   => ['localhost',],
	}	

        file {
          "/etc/apache2/logs":
            ensure  => directory,
            require => Package["apache2"],
	}

	file {
	"/var/www":
	ensure => "directory",
	owner => "root"
	}

}
