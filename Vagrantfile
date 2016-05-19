# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'pathname'
require 'yaml'
require_relative 'lib/ssh_config'
require_relative 'lib/settings'

# get dirname of Vagrantfile
dirname = Pathname.new(__FILE__).dirname

# load yaml vagrant config
vagrant_config = dirname + 'vagrant.yml'
if not File.exists?(vagrant_config)
  # pass empty hash to set defaults
  settings = Settings.build({})
else
  settings = Settings.build(YAML.load_file(vagrant_config))
end

# update ssh config
SSHConfig.update(dirname, settings['domain'], settings['vms'])

Vagrant.configure(2) do |config|
  # hostmanager config
  if settings['hostmanager_enabled']
    config.hostmanager.enabled           = settings['hostmanager_enabled']
    config.hostmanager.ignore_private_ip = settings['hostmanager_ignore_private_ip']
    config.hostmanager.include_offline   = settings['hostmanager_include_offline']
    config.hostmanager.manage_guest      = settings['hostmanager_manage_guest']
    config.hostmanager.manage_host       = settings['hostmanager_manage_host']
  end

  # base shell commands
  config.vm.provision 'shell', inline: settings['shell'] if settings['shell']

  # configure VMs
  settings['vms'].each do |val|
    config.vm.define val['name'] do |item|
      item.vm.box              = val['box']
      item.vm.hostname         = val['name'] + settings['domain']

      # default alias to vm name
      item.hostmanager.aliases = val['aliases'].collect { |a| a + settings['domain'] } if settings['hostmanager_enabled'] and val['aliases']

      # vm network config
      item.vm.network 'private_network', ip: val['ip']

      # vm provider and resource settings
      item.vm.provider val['provider'] do |vb|
        vb.memory = val['memory']
      end

      # disable default synced folder
      item.vm.synced_folder ".", "/vagrant", disabled: settings['disable_default_synced_folder']

      # vm synced folders
      val['synced_directories'].each do |mnt|
        item.vm.synced_folder mnt['src'], mnt['dest'],
          owner: val['application_user'],
          group: val['application_user']
      end

      # vm shell commands
      item.vm.provision 'shell', inline: val['shell'] if val['shell']

      # run ansible on vm
      if val['ansible_playbook']
        item.vm.provision 'ansible' do |ansible|
          ansible.host_key_checking = false
          ansible.inventory_path    = dirname + val['ansible_inventory_path']
          ansible.limit             = 'all'
          ansible.raw_arguments     = val['ansible_raw_arguments']
          ansible.extra_vars        = val['ansible_extra_vars']
          ansible.playbook          = val['ansible_playbook']
        end
      end
    end
  end
end
