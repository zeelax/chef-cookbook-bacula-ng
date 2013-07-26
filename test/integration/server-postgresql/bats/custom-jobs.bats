# -*- shell-script -*-

load helpers/test_helper

@test "can run the custom job" {
    rm -rf /srv/bacula/restore
    echo "run job=test_job client=$MYHOSTNAME yes" | bconsole
    sleep 5
    /etc/bacula/scripts/restore RestoreFiles client=$MYHOSTNAME fileset=test_job current
    sleep 5
    test -f /srv/bacula/restore/tmp/RANDOM
    diff -s /tmp/RANDOM /srv/bacula/restore/tmp/RANDOM
}
