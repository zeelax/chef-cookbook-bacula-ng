# -*- coding: utf-8 -*-

include_recipe 'bacula-ng::_common'

solo_require_attributes 'bacula.fd.password' do
  node.set_unless['bacula']['fd']['password'] = secure_password
  node.save
end

directors = search(:node, 'tags:bacula_director')
if node['$.bacula.director.password'].any? || tagged?('bacula_director') ||
    (%w(bacula-ng::server bacula-ng::director) & node.run_list.expand(node.chef_environment).recipes).any?
  # I'm the director too
  directors << node unless directors.map(&:name).include?(node.name)
end
directors.sort_by!(&:name)

package 'bacula-fd'
service 'bacula-fd'

template '/etc/bacula/bacula-fd.conf' do
  owner 'root'
  group 'bacula'
  mode '0640'
  variables directors: directors
  notifies :restart, 'service[bacula-fd]'
end

# FIXME: DRY
node['bacula']['client']['backup'].map { |job_id| data_bag_item('bacula_jobs', job_id) }.each do |job|
  scripts = Array(job['backup_scripts'])
  directory "/etc/bacula/scripts/#{job['id']}" do
    not_if { scripts.empty? }
  end
  scripts.each do |script|
    script_cookbook, script_file = script.split('::')
    cookbook_file "/etc/bacula/scripts/#{job['id']}/#{script_file}" do
      mode '0500'
      cookbook script_cookbook
      source script_file
    end
  end
end

node['bacula']['client']['restore'].map { |job_id| data_bag_item('bacula_jobs', job_id) }.each do |job|
  scripts = Array(job['restore_scripts'])
  directory "/etc/bacula/scripts/#{job['id']}" do
    not_if { scripts.empty? }
  end
  scripts.each do |script|
    script_cookbook, script_file = script.split('::')
    cookbook_file "/etc/bacula/scripts/#{job['id']}/#{script_file}" do
      mode '0500'
      cookbook script_cookbook
      source script_file
    end
  end
end

tag('bacula_client')

iptables_rule 'port_bacula_fd' do
  variables allowed_ips: directors.map { |n| node.ip_for(n) }.compact.uniq.sort
  only_if node['bacula']['use_iptables']
end
