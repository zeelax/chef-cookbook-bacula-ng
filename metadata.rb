name             "bacula-ng"
maintainer       "Maciej Pasternacki"
maintainer_email "maciej@3ofcoins.net"
license          'MIT'
description      "Bacula"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'database'
depends 'mysql'
depends 'postgresql'
depends 'iptables'
depends 'openssl'
