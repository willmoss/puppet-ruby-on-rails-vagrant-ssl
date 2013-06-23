class bx::settings {
    env_check { vo_lhcb:
        file    => '/etc/profile.d/zfs-env.sh',
        string  => "$settings::l_dir",
        .......
        .......
    }
}
