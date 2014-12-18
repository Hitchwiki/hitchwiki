# -*- mode: ruby -*-
# vi: set ft=ruby :

# Hitchwiki Vagrant setup
# Using http://box.scotch.io/

Vagrant.configure("2") do |config|

  config.vm.box = "scotch/box"
  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.hostname = "scotchbox"

  # Run the import_dev.sh file to configure our environment for development
  config.vm.provision :shell, :path => "scripts/vagrant_bootstrap.sh"

  config.vm.synced_folder ".", "/var/www", :mount_options => ["dmode=777", "fmode=666"]

end
