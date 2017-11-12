# encoding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Hitchwiki Development Vagrant setup

require "yaml"
require "fileutils"

# Config file paths
current_dir = File.dirname(File.expand_path(__FILE__))
settings_file = "#{current_dir}/configs/settings.yml"
settings_file_template = "#{current_dir}/configs/settings-example.yml"

# Copy settings.yml file from template file if it doesn't exist yet
if not File.exist?(settings_file)
  FileUtils.cp(settings_file_template, settings_file)
end

# Load vagrant config file
settings = YAML.load_file(settings_file)

# Configure box
Vagrant.configure("2") do |config|
  config.hostmanager.enabled = settings["vagrant"]["hostmanager_enabled"]
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  config.vm.define "hitchwiki" do |node|
    node.vm.box = "ubuntu/xenial64"
    node.vm.synced_folder ".", "/var/www", :mount_options => ["dmode=777", "fmode=755"]
    node.vm.network :private_network, ip: settings["vagrant"]["private_network_ip"]
    node.vm.hostname = settings["vagrant"]["hostname"]

    # SSH settings https://www.vagrantup.com/docs/vagrantfile/ssh_settings.html
    node.ssh.port = "2222"
    #config.ssh.password = "ubuntu"
    #config.ssh.keys_only = true
    #config.ssh.insert_key = true
    #config.ssh.private_key_path = "~/.ssh/id_rsa"

    # Provision hitchwiki with ansible
#    config.vm.provision :ansible do |ansible|
#      ansible.playbook = "scripts/ansible/deploy.yml"
#    end # https://www.vagrantup.com/docs/provisioning/ansible.html
    config.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "scripts/ansible/hitchwiki.yml"
      ansible.provisioning_path = "/var/www/"
    end # https://www.vagrantup.com/docs/provisioning/ansible_local.html
    # https://www.vagrantup.com/docs/provisioning/basic_usage.html#multiple-provisioners
  end
end
