# -*- mode: ruby -*-
# vi: set ft=ruby :
#
Vagrant.require_version ">= 1.6.0"

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.


boxes = [
    {
        :name => "k8s-master",
        :eth1 => "192.168.56.10",
        :mem => "2048",
        :cpu => "2"
    }
]

Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu2204"
  boxes.each do |opts|
      config.vm.define opts[:name] do |config|
        config.vm.hostname = opts[:name]

        config.vm.provider "vmware_fusion" do |v|
          v.vmx["memsize"] = opts[:mem]
          v.vmx["numvcpus"] = opts[:cpu]
        end

        config.vm.provider "virtualbox" do |v|
          v.customize ["modifyvm", :id, "--memory", opts[:mem]]
          v.customize ["modifyvm", :id, "--cpus", opts[:cpu]]
        end
#        config.vm.network "forwarded_port", guest: 8888, host: 8888
#        config.vm.network "forwarded_port", guest: 3306, host: 3306
        config.vm.network :private_network, ip: opts[:eth1]
        config.vm.network :public_network, ip: opts[:eth2]
      end
  end
  config.vm.provision "shell", privileged: true, path: "./setup.sh"
  config.vm.provision "shell", privileged: true, path: "./docker-install.sh"
  config.vm.provision "shell", privileged: true, path: "./docker-perpare.sh"
end