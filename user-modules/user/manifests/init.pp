class user {
  
  # wordpress group
  group { "wordpress":
    ensure => "present",
  }

  # webapp user
	user { 
    "webapp":
      ensure => present,
      groups => ["sudo","wordpress"],
      membership => minimum,
      shell => "/bin/bash",
		  managehome => true,
		  password => '$6$6OTK2BzD$hNd26Tvge66LEtyC/adhmLaPUb38W7xrpejY2b5qYID2QhvKGL8EBsZ9OfyRj7n9RXT0UBpAX7auWPuO5wUET1', # Iecieviosei8mohcaKai - do not change- hardcoded to capistrano deploy
		  require => Group["wordpress"],
  }

	# install ssh key
	class { "user-sshkey":
		user => "webapp",
		type => "rsa"
	}
	
	

}
