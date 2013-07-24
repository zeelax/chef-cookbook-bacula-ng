BEGIN { port_re = "tcp dpt:" port "$" }
$0 ~ port_re && $3 == "ACCEPT" && $8 == ip { found = 1 ; exit }
END { if ( !found ) { exit 1 } }
