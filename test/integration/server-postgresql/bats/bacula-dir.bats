# -*- shell-script -*-

load helpers/test_helper

@test "bacula-dir is running" {
    pidof bacula-dir
}

@test "configures director" {
    [ "`get_bacula_config bacula-dir.conf Director Name`" = "$MYHOSTNAME:director" ]
    [ "`get_bacula_config bacula-dir.conf Director Password`" = 'swordfish' ]

    [ "`get_bacula_config bacula-dir.conf Storage Name`" = "$MYHOSTNAME:storage" ]
    [ "`get_bacula_config bacula-dir.conf Storage Password`" = 'swordfish' ]
    [ "`get_bacula_config bacula-dir.conf Storage Address`" = "$MYIP" ]

    get_bacula_config bacula-dir.conf Client Name | grep "$MYHOSTNAME"
    get_bacula_config bacula-dir.conf Client Password | grep 'swordfish'
    get_bacula_config bacula-dir.conf Client Address | grep "$MYIP"
}

@test "director lets self in on the firewall" {
    check_iptables ip=$MYIP port=9101
}

@test "can connect with bconsole" {
    echo version | bconsole -u 1
}

@test "database is created and populated" {
    sudo -u postgres psql bacula -c 'SELECT * FROM version;'
}

@test "can back up and restore" {
    rm -rf /srv/bacula/restore
    echo "run job=BackupCatalog client=$MYHOSTNAME yes" | bconsole
    sleep 10                    # FIXME: actually wait
    /etc/bacula/scripts/restore RestoreFiles fileset=Catalog client=$MYHOSTNAME current select all yes
    sleep 10                    # FIXME: actually wait
    [ -f /srv/bacula/restore/var/lib/bacula/bacula.sql ]
}
