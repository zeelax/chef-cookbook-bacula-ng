# -*- shell-script -*-

load helpers/test_helper

@test "bacula-fd is running" {
    pidof bacula-fd
}

@test "configures director for bacula-fd" {
    [ "`get_bacula_config bacula-fd.conf Director Name`" = 'stub:director' ]
    [ "`get_bacula_config bacula-fd.conf Director Password`" = 'swordfish' ]
}

@test "lets director in on the firewall" {
    check_iptables ip=1.1.1.1 port=9102
}

@test "lets localhost in on the firewall" {
    check_iptables ip=127.0.0.1 port=9102
}
