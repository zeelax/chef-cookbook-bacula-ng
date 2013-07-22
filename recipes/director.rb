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
    encoding 'UTF8'
    action :create
  end

  postgresql_database 'bacula::schema' do
    connection host: 'localhost',
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
    action [:create, :grant]
  end

  mysql_database 'bacula::schema' do
    connection db_connection
    database_name 'bacula'
    sql { ::File.read('/usr/share/dbconfig-common/data/bacula-director-mysql/install/mysql') }
    not_if { File.exist?("#{node['mysql']['data_dir']}/bacula/Version.frm") }
  end
else
  raise "Supported databases are 'postgresql' or 'mysql', not #{node['bacula']['database'].inspect}"
end

package 'bacula-console'

template '/etc/bacula/bconsole.conf' do
  owner 'root'
  group 'bacula'
  mode '0640'
end

directory '/etc/bacula/bacula-dir.d' do
  owner 'root'
  group 'bacula'
  mode '0750'
end

storages = search(:node, 'tags:bacula_storage').sort_by(&:name)
clients = search(:node, 'tags:bacula_client').sort_by(&:name)
storages << node if tagged?('bacula_storage') && !storages.map(&:name).include?(node.name)
clients << node if !clients.map(&:name).include?(node.name)

template '/etc/bacula/bacula-dir.conf' do
  owner 'root'
  group 'bacula'
  mode '0640'
  variables :storages => storages, :clients => clients
  notifies :restart, 'service[bacula-director]'
end

tag 'bacula_director'

if node['bacula']['use_iptables']
  include_recipe 'iptables'
  iptables_rule 'port_bacula_dir' do
    variables :allowed_ips => storages.map { |n| node.ip_for(n) }.compact.uniq
  end
end

log "FIXME: custom jobs"
