raise 'Need to run on bacula-dir node' unless tagged?('bacula_director')

include_recipe 'php'
include_recipe 'php::module_gd'
case node['bacula']['database']
when 'mysql'      then include_recipe 'php::module_mysql'
when 'postgresql' then include_recipe 'php::module_pgsql'
end
include_recipe 'apache2'
include_recipe 'apache2::mod_php5'
include_recipe 'apache2::mod_ssl' if node['bacula']['web']['ssl_key_path']

directory '/srv/bacula-web'

tarball = "bacula-web-#{node['bacula']['web']['version']}.tar.gz"
tarball_path = "#{Chef::Config[:file_cache_path]}/#{tarball}"

execute 'install bacula-web' do
  command "tar --no-same-owner --no-same-permissions -xzf #{tarball_path}"
  cwd '/srv/bacula-web'
  action :nothing
end

remote_file tarball_path do
  source "#{node['bacula']['web']['download_url']}#{tarball}"
  checksum node['bacula']['web']['download_checksum']
  notifies :run, 'execute[install bacula-web]', :immediately
end

template '/srv/bacula-web/application/config/config.php' do
  source 'bacula-web-config.php.erb'
  owner 'root'
  group 'www-data'
  mode '0640'
end

directory '/srv/bacula-web/application/view/cache' do
  owner 'root'
  group 'www-data'
  mode '0775'
end

web_app 'bacula-web'
