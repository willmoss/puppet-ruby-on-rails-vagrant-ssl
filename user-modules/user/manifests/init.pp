class user {

	user { 
                "webapp":
                  ensure => present,
                  groups => ["admin", "sudo"],
                  membership => minimum,
                  shell => "/bin/bash",
		  managehome => true,
		  password => '' #openssl passwd -1
        }

}
