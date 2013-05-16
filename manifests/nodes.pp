node precise64 {

	include apache2
	include mysql
	include apache
	include passenger
	include user
	include swap

        # Install apache
	# requires: puppet module install rcoleman/puppet_module 
	class {'apache::mod::ssl':}

	# http , which redirect to ssl
        apache2::site { "bxmediauk.com-http":
		sitedomain => "bxmediauk.com",
		ssl_redirect => true,
	} 
	
	# ssl
	apache2::site { "bxmediauk.com-ssl":
		sitedomain => "bxmediauk.com",
		ssl => true,
		ssl_have_certificates => true
	}
        # bundler
	package {
                "bundler":
                  provider => gem
        }


	# Install MTA
	# class { 'postfix': }

        Class["User"] -> Class["apache2"]		
	Class["swap"] -> Class["passenger"] # passenger requires larger swap
}
