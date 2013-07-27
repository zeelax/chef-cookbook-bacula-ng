include_recipe 'bacula-ng::_common'

solo_require_attributes 'bacula.director.password',
                        'bacula.director.db_password' do
  node.set_unless['bacula']['director']['password'] = secure_password
  node.set_unless['bacula']['director']['db_password'] = secure_password
  node.save
end

package "bacula-director#{node['bacula']['package_flavour']}"
service 'bacula-director'

case node['bacula']['database']
when 'postgresql'
  include_recipe "database::postgresql"
  include_recipe "postgresql::server"

  db_connection = { host: 'localhost',
                    port: node['postgresql']['config']['port'],
                    username: 'postgres',
                    password: node['postgresql']['password']['postgres'] }


  postgresql_database_user 'bacula' do
    connection db_connection
    password node['bacula']['director']['db_password']
    action :create
  end

  postgresql_database 'bacula' do
    connection db_connection
    owner 'bacula'
    encoding 'SQL_ASCII'
    template 'template0'
    action :create
  end

  postgresql_database 'bacula::schema' do
    connection host: 'localhost',
               port: node['postgresql']['config']['port'],
               username: 'bacula',
               password: node['bacula']['director']['db_password']
    database_name 'bacula'
    sql { ::File.read('/usr/share/dbconfig-common/data/bacula-director-pgsql/install/pgsql') }
    not_if { pg_has_table?('bacula', 'job') }
    action :query
  end
when 'mysql'
  include_recipe 'database::mysql'
  include_recipe 'mysql::server'

  db_connection = { host: 'localhost',
                    username: 'root',
                    password: node['mysql']['server_root_password'] }

  mysql_database "bacula" do
    connection db_connection
    encoding 'utf8'
    collation 'utf8_unicode_ci'
  end

  mysql_database_user "bacula" do
    connection db_connection
    password node['bacula']['director']['db_password']
    database_name 'bacula'
    host 'localhost'
    action [:create, :grant]
  end

  mysql_database 'bacula::schema' do
    connection host: 'localhost',
               username: 'bacula',
               password: node['bacula']['director']['db_password']
    database_name 'bacula'
    sql { ::File.read('/usr/share/dbconfig-common/data/bacula-director-mysql/install/mysql') }
    not_if { File.exist?("#{node['mysql']['data_dir']}/bacula/Version.frm") }
    action :query
  end
else
  raise "Supported databases are 'postgresql' or 'mysql', not #{node['bacula']['database'].inspect}"
end

include_recipe 'bacula-ng::client'

directory '/etc/bacula/bacula-dir.d' do
  owner 'root'
  group 'bacula'
  mode '0750'
end

if Chef::DataBag.list.include?('bacula_unmanagedhosts')
  unmanagedhosts = search(:bacula_unmanagedhosts, '*:*')
  unmanagedhosts.each do |uh|
    uh['bacula'] ||= {}
    uh['bacula']['fd'] ||= {}
    uh['bacula']['fd']['name'] ||= uh['id']
  end
else
  unmanagedhosts = []
end

_name = lambda { |sth| sth.respond_to?(:name) ? sth.name : sth['id'] }

storages = search(:node, 'tags:bacula_storage')
storages << node if tagged?('bacula_storage') && !storages.map(&_name).include?(node.name)
storages.sort_by!(&_name)

clients = search(:node, 'tags:bacula_client')
clients.concat unmanagedhosts
clients << node if !clients.map(&_name).include?(node.name)
clients.sort_by!(&_name)

template '/etc/bacula/bacula-dir.conf' do
  owner 'root'
  group 'bacula'
  mode '0640'
  variables :storages => storages, :clients => clients
  notifies :restart, 'service[bacula-director]'
end

search('bacula_jobs', '*:*').each do |job|
  config = job['director_config'] || 'bacula-ng::bacula-dir-job.conf.erb'
  cfg_cookbook, cfg_template = config.split('::')

  clients = search(:node, "bacula_client_backup:#{job['id']}")
  clients << node if !clients.map(&_name).include?(node.name)
  unmanagedhosts.
    select { |uh| Array(uh['bacula']['client']['backup']).include?(job['id']) }.
    each { |uh| clients << uh }
  clients.sort_by!(&_name)

  template "/etc/bacula/bacula-dir.d/job-#{job['id']}.conf" do
    source cfg_template
    cookbook cfg_cookbook
    owner 'root'
    group 'bacula'
    mode '0640'
    variables job: job,
              clients: clients
    notifies :restart, 'service[bacula-director]'
  end
end

tag 'bacula_director'

package 'bacula-console'

template '/etc/bacula/bconsole.conf' do
  owner 'root'
  group 'bacula'
  mode '0640'
end

package 'expect'

cookbook_file '/etc/bacula/scripts/restore' do
  owner 'root'
  group 'root'
  mode '0755'
end

if node['bacula']['use_iptables']
  include_recipe 'iptables'
  iptables_rule 'port_bacula_dir' do
    variables :allowed_ips => storages.map { |n| node.ip_for(n) }.compact.uniq
  end
end
