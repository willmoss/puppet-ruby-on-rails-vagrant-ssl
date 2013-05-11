# Class: base::swap
#
# This class manages swapspace on a node.
#
# Parameters:
# - $ensure Allows creation or removal of swapspace and the corresponding file.
# - $swapfile Defaults to /mnt which is a fast ephemeral filesystem on EC2 instances.
#             This keeps performance reasonable while avoiding I/O charges on EBS.
# - $swapfilesize Size of the swapfile in MB. Defaults to memory size, but see Requires.
#
# Todo:
#   Manage /etc/fstab
#
# Actions:
#   Creates and mounts a swapfile.
#   Umounts and removes a swapfile.
#
# Requires:
#   memorysizeinbytes fact - See:
#   https://blog.kumina.nl/2011/03/facter-facts-for-memory-in-bytes/
#
# Sample Usage:
#   class { 'base::swap':
#     ensure => present,
#   }
#
#   class { 'base::swap':
#     ensure => absent,
#   }
#
#   If you have the swapsizeinbytes fact (see Requires), you could also do:
#     if $::swapsizeinbytes == 0 {
#         include base::swap
#     }
#
class swap(
    $ensure         = 'present',
    $swapfile       = '/mnt/swap.1', # Where to create the swapfile.
    
    #sets 3GB swap filesize    
    #$swapfilesize   = $::memorysizeinbytes/1000000 # Size in MB. Defaults to memory size.

) {
    if $ensure == 'present' {
        exec { 'Create swap file':
            command     => "/bin/dd if=/dev/zero of=${swapfile} bs=1M count=3M",
            creates     => $swapfile,
        }

        exec { 'Attach swap file':
            command => "/sbin/mkswap ${swapfile} && /sbin/swapon ${swapfile}",
            require => Exec['Create swap file'],
            unless  => "/sbin/swapon -s | grep ${swapfile}",
        }
    }
    elsif $ensure == 'absent' {
        exec { 'Detach swap file':
            command => "/sbin/swapoff ${swapfile}",
            onlyif  => "/sbin/swapon -s | grep ${swapfile}",
        }

        file { $swapfile:
            ensure  => absent,
            require => Exec['Detach swap file'],
        }
    }
}
