node precise64 {

	include apache2
	include mysql
	include apache
	include passenger
	include user

        # Install apache
	# requires: puppet module install rcoleman/puppet_module 
	class {'apache::mod::ssl':}

	# http
        apache2::site { "localhost-http":
		sitedomain => "localhost"
	} 
	
	# ssl
	apache2::site { "localhost-ssl":
		sitedomain => "localhost",
		ssl => true,
		ssl_have_certificates => false
	}
        # bundler
	package {
                "bundler":
                  provider => gem
        }

        Class["User"] -> Class["apache2"]		

}
