# -*- ruby -*-
site :opscode

metadata
cookbook 'apt'
cookbook 'chef-solo-search', github: 'edelight/chef-solo-search'

group :integration do
  cookbook "minitest-handler"
  cookbook "bacula-ng-test", path: "./test/cookbooks/bacula-ng-test"
end
