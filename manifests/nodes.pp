node precise64 {

	include apache2
	include mysql
	include passenger
	include user
	include swap
  include php 

  # Install apache
  class {'apache':
     mpm_module => prefork,
  }
  
	# http , which redirect to ssl
  apache2::site { "bxmediauk.com-http":
		#sitedomain => "bxmediauk.com",
		sitedomain => "localhost",
		ssl_redirect => true,
	} 
	
	# define different rack environments
	$rack = [
		{'path' => '/trade','dir' => '/home/webapp/bxmediauk.com.wmtrade/current/public/'}, 
		{'path' => '/bicho','dir' => '/home/webapp/bxmediauk.com.bicho/current/public/'},
	]

	# ssl
	apache2::site { "bxmediauk.com-ssl":
		#sitedomain => "bxmediauk.com",
		sitedomain => "localhost",
		ssl => true,
		#ssl_have_certificates => true,
		ssl_have_certificates => false,
		rack_envs => $rack,
		documentroot => "/home/webapp/bxmediauk.com.wordpress/",
		priority => 25, 
		before => Class['wordpress'],
	}
        
	# install wordpress?
	class { 'wordpress':
		install_dir => '/home/webapp/bxmediauk.com.wordpress',
		wp_owner    => 'webapp',
		db_user     => 'wordpress',
		db_password => 'wordpress12',
		create_db => false,
		create_db_user => false,
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
