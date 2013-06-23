class user {
  
  # wordpress group
  group { "wordpress":
    ensure => "present",
  }

	# install ssh key
	class { "user-sshkey":
		user => "webapp",
		type => "rsa"
	}
	
}

import "webapp.pp"
