class php {
    
  package { "php5":
    ensure => present,
  }
 
  package { "libapache2-mod-php5":
    ensure => present,
    require => Package["php5"],
  }
  
  file {'/etc/php.ini':
    ensure => file,
  }
  
  file { "php5.load":
    path => "/etc/apache2/mods-available/php5.load",
    ensure => file,
    owner => 'root',
    group => 'root',
    mode => '0644',
    content => "LoadModule php5_module /usr/lib/apache2/modules/libphp5.so \n",
    require => Package["libapache2-mod-php5"],
    notify => Service['apache2'],
  }
  
  # set up PHP
  file { 'php.conf':
    ensure => file,
    path => "/etc/apache2/mods-available/php.conf",
    content => template('php/php.conf.erb'),
    require => File["php5.load"],
  }

  file{ "php5.load symlink":
      path => "/etc/apache2/mods-enabled/php5.load",
      ensure => link,
      target => "/etc/apache2/mods-available/php5.load",
      owner => 'root',
      group => 'root',
      mode => '0644',
      require => File["php5.load"],
      notify => Service['apache2'],
  }

  file{ "php.conf symlink":
        path => "/etc/apache2/mods-enabled/php5.conf",
        ensure => link,
        target => "/etc/apache2/mods-available/php.conf",
        owner => 'root',
        group => 'root',
        mode => '0644',
        require => File["php.conf"],
        notify => Service['apache2'],
  }

  

}
