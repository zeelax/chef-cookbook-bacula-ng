# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.hostname = "bacula-ng"

  config.vm.box = "opscode-ubuntu-12.04"
  config.vm.box_url = "https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box"

  config.ssh.max_tries = 40
  config.ssh.timeout   = 120

  config.berkshelf.enabled = true
  config.omnibus.chef_version = :latest

  config.vm.provision :chef_solo do |chef|
    chef.run_list = [
      "recipe[bacula-ng-test::iptables]",
      "recipe[chef-solo-search]",
      "recipe[apt]",
      "recipe[bacula-ng::server]"
    ]
    chef.json = {
      bacula: {
        director: { db_password: "swordfish", password: "swordfish" },
        fd: { password: "swordfish" },
        mon: { password: "swordfish" },
        storage: { password: "swordfish" }
      },
      postgresql: { password: { postgres: "swordfish" }}}
  end
end
