default['bacula']['database'] = 'postgresql'
default['bacula']['restore_dir'] = '/srv/bacula/restore'
default['bacula']['use_iptables'] = true

default['bacula']['storage']['name'] = "#{name}:storage"
default['bacula']['storage']['directory'] = '/srv/bacula/storage'
default['bacula']['storage']['maximum_concurrent_jobs'] = 20

default['bacula']['mon']['name'] = "#{name}:mon"

default['bacula']['director']['name'] = "#{name}:director"
default['bacula']['director']['mailto'] = 'root@localhost'

default['bacula']['fd']['name'] = node.name

default['bacula']['client']['backup'] = []
default['bacula']['client']['restore'] = []
