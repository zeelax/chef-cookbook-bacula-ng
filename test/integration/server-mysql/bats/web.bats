# -*- shell-script -*-

load helpers/test_helper

@test "runs bacula-web" {
    FQDN=`hostname --fqdn`
    out=`mktemp`
    curl http://$FQDN/ > $out
    fgrep '<title>Bacula-Web - Dashboard</title>' $out
    fgrep 'Version 5.2.13-1' $out
    fgrep BackupCatalog $out
    rm -f $out
}
