include_recipe 'bacula-ng::_storage_pre'

package "bacula-sd#{node['bacula']['package_flavour']}"
service 'bacula-sd'

directory node['bacula']['storage']['directory'] do
  owner 'bacula'
  group 'bacula'
  mode '0700'
  recursive true
end

directors = search(:node, 'tags:bacula_director')
directors << node if !directors.map(&:name).include?(node.name) && tagged?('bacula_director')
directors.sort_by!(&:name)

clients = search(:node, 'tags:bacula_client')
clients << node if !clients.map(&:name).include?(node.name) && tagged?('bacula_client')
clients.sort_by(&:name)

if directors.empty?
  Chef::Log.warn("Couldn't find Bacula director, using stub entry")
  directors = [{'bacula' => { 'director' => {
          'stub' => true,
          'name' => 'dummy',
          'password' => secure_password }}}]
end

template '/etc/bacula/bacula-sd.conf' do
  owner 'root'
  group 'bacula'
  mode '0640'
  variables :directors => directors
  notifies :restart, "service[bacula-sd]"
end

if node['bacula']['use_iptables']
  include_recipe 'iptables'
  iptables_rule 'port_bacula_sd' do
    variables :allowed_ips => (clients+directors).map { |n| node.ip_for(n) }.compact.uniq.sort
  end
end

tag('bacula_storage')
