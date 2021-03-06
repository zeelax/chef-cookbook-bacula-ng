HELPERS="$BATS_TEST_DIRNAME/helpers"

check_iptables () {
    vars=''
    while [ -n "$1" ] ; do
        vars="$vars -v $1"
        shift
    done
    iptables -L -v -n | awk $vars -f $HELPERS/check_iptables.awk
}

get_bacula_config () {
    awk -v section="$2" -v option="$3" \
        -f $HELPERS/get_bacula_config.awk \
        "/etc/bacula/$1"
}
