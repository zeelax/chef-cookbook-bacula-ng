# -*- shell-script -*-

load helpers/test_helper

@test "can see the legacy hosts" {
    get_bacula_config bacula-dir.conf Client Name | grep legacy
    get_bacula_config bacula-dir.conf Client Password | grep 'WHATEVER'
    get_bacula_config bacula-dir.conf Client Address | grep '1\.2\.3\.4'
    get_bacula_config bacula-dir.d/job-test_job.conf Job Name | grep 'legacy:test_job'
}
