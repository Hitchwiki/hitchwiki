# -*- mode: ruby -*-
# vi: set ft=ruby :

# Hitchwiki Development Vagrant setup
# Using http://box.scotch.io/
#
# Modified from https://github.com/scotch-io/scotch-box/blob/master/Vagrantfile
# Added https://github.com/smdahlen/vagrant-hostmanager

Vagrant.configure("2") do |config|

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  config.vm.box = "scotch/box"
  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.hostname = "hitchwiki.dev"

  # Run Mailcatcher on every `vagrant up`
  config.vm.provision "shell", inline: "/home/vagrant/.rbenv/shims/mailcatcher --http-ip=0.0.0.0", run: "always"

  # Install Hitchwiki with all of its dependencies
  # Uncomment the last part if you don't want to install VisualEditor & Parsoid
  config.vm.provision :shell, :path => "scripts/server_install.sh" # , :args => ["--no-visualeditor"]

  config.vm.synced_folder ".", "/var/www", :mount_options => ["dmode=777", "fmode=755"]

end
