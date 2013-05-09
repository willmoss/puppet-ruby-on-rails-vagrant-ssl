Exec {
  path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
}

/*
include apache

	apache::vhost { "tryme-ssl":
			    port            => 443,
			    ssl             => true,
			    docroot         => "/var/www/",
			    serveradmin     => "web@example.com",
			    ssl_cert  => "/etc/apache2/ssl/tryme.crt",
			    ssl_key   => "/etc/apache2/ssl/tryme.key",
		 }   

*/





#ssl_pkey {
#  '/etc/apache2/ssl/me.key':
#ensure => 'present'
#}

# create certificate
#x509_cert {
#  '/etc/apache2/ssl/${vhost_domain}.crt':
#}

import "nodes.pp"


#notify {"The value is: ${modulepath}": }

