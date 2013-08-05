default['bacula']['database'] = 'postgresql'
default['bacula']['restore_dir'] = '/srv/bacula/restore'
default['bacula']['use_iptables'] = true


default['bacula']['storage']['name'] = "#{name}:storage"
default['bacula']['storage']['directory'] = '/srv/bacula/storage'
default['bacula']['storage']['maximum_concurrent_jobs'] = 20

default['bacula']['mon']['name'] = "#{name}:mon"

default['bacula']['director']['name'] = "#{name}:director"
default['bacula']['director']['mailto'] = 'root@localhost'
default['bacula']['director']['volume_retention'] = '1000 years'

default['bacula']['fd']['name'] = node.name

default['bacula']['client']['backup'] = []
default['bacula']['client']['restore'] = []
default['bacula']['client']['file_retention'] = '1 year'
default['bacula']['client']['job_retention'] = '1000 years'

default['bacula']['web']['domain'] = node['fqdn']
default['bacula']['web']['version'] = '5.2.13-1'
default['bacula']['web']['download_url'] = 'http://www.bacula-web.org/tl_files/downloads/'
default['bacula']['web']['download_checksum'] = 'c9787c1999a87af4086b296fc0d2edba9f65d16cf9b4a90a818d109d2e76844f'
