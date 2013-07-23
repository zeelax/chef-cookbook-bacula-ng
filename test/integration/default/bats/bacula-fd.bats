# -*- shell-script -*-

@test "bacula-fd is running" {
    pidof bacula-fd
}

@test "configures director for bacula-fd" {
    sed -n '/^Director/,/}$/p' /etc/bacula/bacula-fd.conf | grep 'Name *= *stub:director'
    sed -n '/^Director/,/}$/p' /etc/bacula/bacula-fd.conf | grep 'Password *= *swordfish'
}

@test "lets director in on the firewall" {
    iptables -L -v -n | awk -v ip=1.1.1.1 -v port=9102 -f $BATS_TEST_DIRNAME/fixtures/check_iptables.awk
}

@test "lets localhost in on the firewall" {
    iptables -L -v -n | awk -v ip=127.0.0.1 -v port=9102 -f $BATS_TEST_DIRNAME/fixtures/check_iptables.awk
}
