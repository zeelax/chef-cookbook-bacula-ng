# -*- shell-script -*-

load helpers/test_helper

@test "bacula-fd is running" {
    pidof bacula-fd
}

@test "configures director for bacula-fd" {
    [ "`get_bacula_config bacula-fd.conf Director Name`" = "`hostname | cut -d. -f1`:director" ]
    [ "`get_bacula_config bacula-fd.conf Director Password`" = 'swordfish' ]
}

@test "file daemon lets self in on the firewall" {
    check_iptables ip=$MYIP port=9102
}
