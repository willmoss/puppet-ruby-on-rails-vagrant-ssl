class nodejs($package = 'nodejs', $global_packages = []) {
   
    if ($operatingsystem == 'Ubuntu') {
        apt::source {'nodejs':
            before      => Package[$package],
            location    => 'http://ppa.launchpad.net/chris-lea/node.js/ubuntu',
            release     => 'raring',
            repos       => 'main',
            key         => 'C7917B12',
        }
    }
   
    package{$package:
        ensure          => present,
        name            => $package,
    }
 
    package{$global_packages:
        ensure          => present,
        provider        => npm,
    }
 
    package{'npm':
        ensure          => latest,
        provider        => npm,
    }    
}
