class mysql {
	package {
		"mysql-server":
		  ensure => installed,
		  before => File["/etc/mysql/my.cnf"]
	}
	file {
		"/etc/mysql/my.cnf":
		  owner => root,
		  group => root,
		  mode  => 644,
		  source => "puppet:///modules/mysql/my.cnf"
	}
	service {
		"mysql":
		  ensure => running,
		  subscribe => File["/etc/mysql/my.cnf"],
		  provider => 'upstart',
		  hasrestart => 'true',
		  hasstatus => 'true'
	}
	exec {
	  "mysql_password":
	    unless   => "mysqladmin -uroot -proot status",
	    command  => "mysqladmin -uroot password root",
	    require  => Service[mysql];
	  "massiveapp_db":
	    unless  => "mysql -uroot -proot two_factor_production",
	    command => "mysql -uroot -proot -e 'create database two_factor_production'",
	    require => Exec["mysql_password"];
	  "wordpress_db":
	    unless  => "mysql -uroot -proot wordpress",
	    command => "mysql -uroot -proot -e \"create database wordpress; CREATE USER 'wordpress'@'localhost' IDENTIFIED BY 'wordpress12'; GRANT ALL PRIVILEGES ON * . * TO 'wordpress'@'localhost';\"",
	    require => Exec["mysql_password"];
	}
}
