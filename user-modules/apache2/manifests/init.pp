class apache2 {


	define makehomedir {

		file {

			[ "/home/webapp/${title}/", "/home/webapp/${title}/current/", "/home/webapp/${title}/current/public/" ]:
			#"/home/webapp/${title}/current/", "/home/webapp/${title}/current/public/" ]:
				ensure => "directory",
				owner => "webapp",
				mode => 777, #CHANGEME!
				before => Class["apache"]
			}

	}


	define site( $ssl = false, $ssl_have_certificates = false, $sitedomain = "", $documentroot = "" ) {
		include apache2
		if $sitedomain == "" {
			$vhost_domain = $name
		} else {
			$vhost_domain = $sitedomain
		}
		if $documentroot == "" {
			$vhost_root = "/home/webapp/${vhost_domain}/current/public/"
		} else {
			$vhost_root = $documentroot
		}
                
		if !defined(Makehomedir[$vhost_domain]) {
			makehomedir{ $vhost_domain: }
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
				  	 template => "/etc/puppet/user-modules/apache2/templates/cert.simple.erb",
					 require => File["/etc/apache2/ssl"],
				}
			
			} 

			# its not possible to do namevirtualhost on SSL
			apache::vhost { $name:
					  port            => 443,
					  ssl             => true,
					  docroot         => $vhost_root,
					  logroot         => "/var/log/apache2/${vhost_domain}-ssl/",
					  serveradmin     => "info@bxmediauk.com",
					  ssl_cert        => "/etc/apache2/ssl/${vhost_domain}.crt",
					  ssl_key         => "/etc/apache2/ssl/${vhost_domain}.key",
			}

		}
		 else {

			apache::vhost { $name:
				    priority        => "10",
				    vhost_name      => "*",
				    port            => "80",
				    docroot         => $vhost_root,
				    logroot         => "/var/log/apache2/${vhost_domain}/",
				    serveradmin     => "info@bxmediauk.com",
				    servername      => $vhost_domain,				    
				    #serveraliases   => ["localhost",],
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
