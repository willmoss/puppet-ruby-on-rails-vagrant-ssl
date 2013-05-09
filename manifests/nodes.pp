node precise64 {

	include apache2
	include mysql
	#include advance2 
	include passenger
	include apache
	
	# Install required modules
	#module { "puppetlabs/apache":
	#  ensure   => installed,
	#  before => Class["apache2"]
	#}

	#module { "camptocamp/openssl":
	#  ensure   => installed,
	#  before => Class["apache2"]
	#}

	# Install apache
	# requires: puppet module install rcoleman/puppet_module 
	class {'apache::mod::ssl':}

	# http
        #apache2::site { "localhost": } 
	
	# ssl
	apache2::site { "localhost":
		ssl => true,
		ssl_have_certificates => false
	}

	# Use this to add snippets to conf.d	
	#apache2::snippet { "site-specific.conf": }
		
}
