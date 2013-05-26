class apache2 {


	define makehomedir {

		file {

			[ "/home/webapp/${title}/", "/home/webapp/${title}/current/", "/home/webapp/${title}/current/public/" ]:
				ensure => "directory",
				owner => "webapp",
				mode => 775, #CHANGEME!
				before => Class["apache"],
				replace => false,
			}

	}


	define site( $ssl = false, $ssl_have_certificates = false, $ssl_redirect = false, $sitedomain = "", $documentroot = "", $wordpress = false, $rack_envs = [], $priority="10") {
		include apache2
		#include wordpress
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

				#notify { "Creating SSL certificates for ${vhost_domain}": }

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
				
				# create request
				x509_request { "/etc/apache2/ssl/${vhost_domain}.csr":
          ensure      => present,
          password    => 'j(D$',
          private_key => "/etc/apache2/ssl/${vhost_domain}.key",
          force       => false,
        }

				# its not possible to do namevirtualhost on SSL
				apache::vhost { $name:
					  port            => 443,
					  ssl             => true,
					  docroot         => $vhost_root,
					  logroot         => "/var/log/apache2/${vhost_domain}-ssl/",
					  servername      => $vhost_domain,
					  serveradmin     => "info@bxmediaus.com",
					  ssl_cert        => "/etc/apache2/ssl/${vhost_domain}.crt",
					  ssl_key         => "/etc/apache2/ssl/${vhost_domain}.key",
					  priority        => $priority,
					  
				}
			
			} else {

				file {
					"/etc/apache2/ssl/${vhost_domain}.crt":
					ensure => present,
					mode => 644,
					owner => root,
					group => root,
					source => "puppet:///modules/apache2/${vhost_domain}.crt",
					notify => Service["apache2"],
				}
	 
				file {
					"/etc/apache2/ssl/${vhost_domain}.key":
					ensure => present,
					mode => 644,
					owner => root,
					group => root,
					source => "puppet:///modules/apache2/${vhost_domain}.key",
					notify => Service["apache2"],
				}

				file {
					"/etc/apache2/ssl/${vhost_domain}.bundle.crt":
					ensure => present,
					mode => 644,
					owner => root,
					group => root,
					source => "puppet:///modules/apache2/${vhost_domain}.bundle.crt",
					notify => Service["apache2"],
				}

				# its not possible to do namevirtualhost on SSL
				apache::vhost { $name:
				    servername      => $vhost_domain,
					  port            => 443,
					  ssl             => true,
					  docroot         => $vhost_root,
					  logroot         => "/var/log/apache2/${vhost_domain}-ssl/",
					  serveradmin     => "info@bxmediaus.com",
					  ssl_cert        => "/etc/apache2/ssl/${vhost_domain}.crt",
					  ssl_key         => "/etc/apache2/ssl/${vhost_domain}.key",
				   	ssl_chain       => "/etc/apache2/ssl/${vhost_domain}.bundle.crt",
				   	priority        => $priority,
				}

			}

			# set up different rack environments
			$config_file = "/etc/apache2/sites-enabled/${priority}-${name}.conf"
			
			addrackenvs { $rack_envs:
			  configfile => $config_file,
			  docroot => $vhost_root,
			}

		}
		 else {
			# is it an SSL redirect node?
			if $ssl_redirect == true {

				apache::vhost { $name:
					    priority        => $priority,
					    vhost_name      => "*",
					    port            => "80",
					    docroot         => $vhost_root,
					    logroot         => "/var/log/apache2/${vhost_domain}/",
					    serveradmin     => "info@bxmediaus.com",
					    servername      => $vhost_domain,
					    rewrite_cond    => "%{HTTPS} off",
					    rewrite_rule    => "(.*) https://%{HTTP_HOST}%{REQUEST_URI}",				    
					    #serveraliases   => ["localhost",],
				}
			}

		}

	}

	define addrackenvs ($configfile, $docroot) {
	  
	  $dir = $title['dir']
	  $path = $title['path']
	  
	  # check dir exists & symlink
    exec { $dir:
        path    => [ '/bin', '/usr/bin' ],
        command => "mkdir -p ${dir}",
        unless  => "test -d ${dir}",
    }
    
    #notice("docroot: ${docroot} , path: ${path}")
    
		file { "${docroot}${path}":
       ensure => 'link',
       target => $dir,
       require => Exec[$dir],
    }
	  
	  # this is a hack
	  
	  # remove </VirtualHost> directive
	  file_line { "${path} remove virtualHost": 
				line => "</VirtualHost>", 
				path => $configfile, 
				#match => "</VirtualHost>", 
				ensure => absent,
				require => File["${docroot}${path}"],
		}
	  
	  file_line { $path: 
				line => "\n\n  RackBaseURI ${path}\n  <Directory ${dir}>\n  Options -MultiViews\n  </Directory>\n\n", 
				path => $configfile,
				ensure => present,
				require => File_line["${path} remove virtualHost"],
		}
		
		# add </VirtualHost> directive again
		file_line { "${path} add virtualHost": 
				line => "</VirtualHost>", 
				path => $configfile, 
				#match => "</VirtualHost>", 
				ensure => present,
				require => File_line[$path],
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
