Exec {
  path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
}


# test create directory


#file { [ "/etc/dir1/", "/etc/dir1/dir2/", "/etc/dir1/dir2/dir3/" ]:
#    ensure => "directory",
#}


import "nodes.pp"

