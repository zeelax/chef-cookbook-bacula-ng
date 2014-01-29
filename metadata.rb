name             "bacula-ng"
maintainer       "Maciej Pasternacki"
maintainer_email "maciej@3ofcoins.net"
license          'MIT'
description      "Bacula"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.0'

depends 'apache2'
depends 'chef-solo-search'
depends 'database'
depends 'iptables'
depends 'mysql'
depends 'openssl'
depends 'php'
depends 'postgresql'
