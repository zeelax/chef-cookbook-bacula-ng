default['bacula']['database'] = 'postgresql'
default['bacula']['use_iptables'] = true

default['bacula']['storage']['name'] = "#{name}:storage"
default['bacula']['storage']['directory'] = '/srv/bacula'
default['bacula']['storage']['maximum_concurrent_jobs'] = 20

default['bacula']['mon']['name'] = "#{name}:mon"

default['bacula']['director']['name'] = "#{name}:director"
default['bacula']['director']['mailto'] = 'root@localhost'

default['bacula']['fd']['name'] = "#{name}"
