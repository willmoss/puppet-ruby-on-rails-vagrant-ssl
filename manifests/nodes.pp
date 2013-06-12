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
  apache2::site { "bxmediaus.com-http":
		sitedomain => "bxmediaus.com",
		#sitedomain => "localhost",
		ssl_redirect => true,
	} 
	
	# define different rack environments
	$rack = [
		{'path' => '/trade','dir' => '/home/webapp/bxmediaus.com.wmtrade/current/public/'}, 
		{'path' => '/bicho','dir' => '/home/webapp/bxmediaus.com.bicho/current/public/'},
		{'path' => '/p2pexchange','dir' => '/home/webapp/bxmediaus.com.p2pexchange/current/public/'},
	]

	# ssl
	apache2::site { "bxmediaus.com-ssl":
		sitedomain => "bxmediaus.com",
		#sitedomain => "localhost",
		ssl => true,
		ssl_have_certificates => true,
		#ssl_have_certificates => false,
		rack_envs => $rack,
		documentroot => "/home/webapp/bxmediaus.com.wordpress/",
		priority => 25, 
		before => Class['wordpress'],
	}
        
	# install wordpress?
	class { 'wordpress':
		install_dir => '/home/webapp/bxmediaus.com.wordpress',
		wp_owner    => 'webapp',
		db_user     => 'wordpress',
		db_password => 'wordpress12',
		create_db => false,
		create_db_user => false,
	}
	
	# install ftp for wordpress plugins
	class { 'vsftpd':
    anonymous_enable  => 'NO',
    write_enable      => 'YES',
    ftpd_banner       => 'FTP Server',
    chroot_local_user => 'NO'
    #userlist_enable => 'YES',
    #userlist_file
    #userlist_deny => 'NO',
  }
  
  # TO DO: install VPN server http://www.howtogeek.com/51237/setting-up-a-vpn-pptp-server-on-debian/
  
  # wordpress user (for ftp)
  user { "wordpress":
    ensure => present,
    groups => ["wordpress"],
    membership => minimum,
    home => "/home/webapp/bxmediaus.com.wordpress",
    password => '$1$Jp9gahZj$5fsPBPfikpkClvQASFkJ01', #password='default' (generated by `openssl passwd -1`)
    require => Class['wordpress'], Group["wordpress"],
  }
  
  # make owner of dir
  exec { "wordpress chown":,
    command => "/bin/chown -R webapp:wordpress /home/webapp/bxmediaus.com.wordpress",
    path => '/bin',
    user => 'root'
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
