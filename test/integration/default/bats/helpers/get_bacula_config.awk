BEGIN { section_re = "^" section " *{" }
/}$/ { inside=0 }
inside && $1==option { print $3 }
$0 ~ section_re { inside=1 }
