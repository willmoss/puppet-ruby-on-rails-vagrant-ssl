class apache2 {

	define site( $ssl = false, $ssl_have_certificates = false, $sitedomain = "", $documentroot = "" ) {
		include apache2
		if $sitedomain == "" {
			$vhost_domain = $name
		} else {
			$vhost_domain = $sitedomain
		}
		if $documentroot == "" {
			$vhost_root = "/var/www/${name}"
		} else {
			$vhost_root = $documentroot
		}

		if $ssl == true {

			if $ssl_have_certificates == false {		

				$commonname = $vhost_domain

				# create pkey
				ssl_pkey { 
				  "/etc/apache2/ssl/${vhost_domain}.key":
					ensure => present,
					require => File["/etc/apache2/ssl"],
				}

				# create certificate
				x509_cert { 
				  "/etc/apache2/ssl/${vhost_domain}.crt":
					 ensure => present,
					 template => "/etc/puppet/user-modules/apache2/templates/cert.simple.cnf",
					 require => File["/etc/apache2/ssl"],
				}
			
			} 

			apache::vhost { "${vhost_domain}-ssl":
					  port            => 443,
					  ssl             => true,
					  docroot         => $vhost_root,
					  serveradmin     => "web@example.com",
					  ssl_cert  => "/etc/apache2/ssl/${vhost_domain}.crt",
					  ssl_key   => "/etc/apache2/ssl/${vhost_domain}.key",
			}

		}
		 else {

			apache::vhost { "localhost":
				    priority        => "10",
				    vhost_name      => "localhost",
				    port            => "80",
				    docroot         => "/var/www/",
				    logroot         => "/var/www/",
				    serveradmin     => "webmaster@example.com",
				    serveraliases   => ["localhost",],
			}

		}
	}


	define snippet() {
		file { 
		  "/etc/apache2/conf.d/${name}":
	            source => "puppet:///modules/apache/${name}",
		    notify => Service["apache2"],
		}
	}


	file {
		"/etc/apache2/ssl":
		ensure => "directory",
	}

}
