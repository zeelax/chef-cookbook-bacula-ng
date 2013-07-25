# -*- shell-script -*-

load helpers/test_helper

@test "bacula-sd is running" {
    pidof bacula-sd
}

@test "configures director for bacula-sd" {
    [ "`get_bacula_config bacula-sd.conf Director Name | head -n 1`" = "`hostname | cut -d. -f1`:director" ]
    [ "`get_bacula_config bacula-sd.conf Director Password | head -n 1`" = 'swordfish' ]
}

@test "storage daemon lets self in on the firewall" {
    check_iptables ip=$MYIP port=9103
}
