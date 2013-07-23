include_recipe 'bacula-ng::_common'

solo_require_attributes 'bacula.fd.password' do
  node.set_unless['bacula']['fd']['password'] = secure_password
  node.save
end

directors = search(:node, 'tags:bacula_director')
if node['$.bacula.director.password'].any? || tagged?('bacula_director') ||
    (%w[bacula-ng::server bacula-ng::director] & node.run_list.expand(node.chef_environment).recipes).any?
  # I'm the director too
  directors << node unless directors.map(&:name).include?(node.name)
end
directors.sort_by!(&:name)

package 'bacula-fd'
service 'bacula-fd'

log "directors: #{directors.inspect}"

template '/etc/bacula/bacula-fd.conf' do
  owner 'root'
  group 'bacula'
  mode '0640'
  variables :directors => directors
  notifies :reload, "service[bacula-fd]"
end

tag('bacula_client')

if node['bacula']['use_iptables']
  allowed_ips = directors.map { |n| node.ip_for(n) }.compact.uniq
  iptables_rule 'port_bacula_fd' do
    variables :allowed_ips => allowed_ips
  end
end

log "FIXME: custom modules"
