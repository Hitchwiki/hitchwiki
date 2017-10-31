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

Vagrant.configure("2") do |config|

  config.hostmanager.enabled = settings["vagrant"]["hostmanager_enabled"]
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  config.ssh.username = "ubuntu"
#  config.ssh.username = "hitchwiki"
  config.ssh.password = settings["phpmyadmin_password"]
  config.ssh.private_key_path = "~/.ssh/id_rsa"

  config.vm.define "hitchwiki" do |node|
    node.vm.box = "ubuntu/xenial64"
    node.vm.synced_folder ".", "/var/www", :mount_options => ["dmode=777", "fmode=755"]
    node.vm.network :private_network, ip: settings["vagrant"]["private_network_ip"]
    node.vm.hostname = settings["domain"]
#    node.vm.hostname = settings["vagrant"]["hostname"]
    # Provision machine using Ansible
    # https://www.vagrantup.com/docs/provisioning/ansible.html
    config.vm.provision :ansible do |ansible|
      #ansible.verbose = "v"
      ansible.inventory_path = "hosts"
      ansible.playbook = "scripts/ansible/deploy.yml"
      ansible.force_remote_user = 1
    end
  end
end
