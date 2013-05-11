# http://www.burgundywall.com/tech/puppet-ssh_authorized_key-and-id_rsa-pub/

class user-sshkey($user,$type) {
 
        # out with old
        file { "/home/$user/.ssh/id_dsa": ensure=>absent }
        file { "/home/$user/.ssh/id_dsa.pub": ensure=>absent }
 
        # in with the new
        file { "/home/$user/.ssh/id_$type":
                ensure  => present,
                source  => "puppet:///modules/user-sshkey/$user/id_$type",
                owner   => $user,
                group   => $user,
                mode    => 0600,
        }
        file { "/home/$user/.ssh/id_$type.pub":
                ensure => present,
                source => "puppet:///modules/user-sshkey/$user/id_$type.pub",
                owner   => $user,
                group   => $user,
                mode    => 0644,
        }
 
        # install the new key
        ssh_authorized_key { "$user-auth-key":
                ensure  => present,
                user    => $user,
                type    => "ssh-$type",
                key     => generate( "/etc/puppet/bin/extract_key", "/etc/puppet/user-modules/user-sshkey/files/$user/id_$type.pub" ),
                require => [File["/home/$user/.ssh/id_$type.pub"]],
        }
}
