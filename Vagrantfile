# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.ssh.forward_agent = true

  config.vm.provider "virtualbox" do |v|
    v.memory = 2024
    v.cpus = 2
  end

  config.vm.provision :shell, :inline => "/vagrant/vagrant/provision.sh #{`whoami`}"
end

