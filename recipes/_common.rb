# -*- coding: utf-8 -*-

include_recipe 'chef-solo-search' if Chef::Config[:solo]

chef_gem 'chef-helpers' do
  version '~> 0.0.7'
end
require 'chef-helpers'

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

node.set['bacula']['package_flavour'] =
  case node['bacula']['database']
  when 'mysql' then '-mysql'
  when 'postgresql' then '-pgsql'
  else raise "Unknown bacula.database #{node['bacula']['database'].inspect}"
  end

solo_require_attributes 'bacula.mon.password' do
  node.set_unless['bacula']['mon']['password'] = secure_password
end

file '/etc/bacula/common_default_passwords' do
  action :delete
end
