# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'fileutils'
require 'pathname'
require 'tempfile'
require 'yaml'

# ===== Settings Loader =====

def load_settings(overrides)
  # default settings
  settings = {
    'ansible_extra_vars'            => {},
    'ansible_inventory_path'        => 'vagrant.py',
    'ansible_limit'                 => 'all',
    'ansible_playbook'              => nil,
    'ansible_raw_arguments'         => nil,
    'box'                           => 'ubuntu/trusty64',
    'disable_default_synced_folder' => true,
    'domain'                        => '.local',
    'hostmanager_enabled'           => true,
    'hostmanager_ignore_private_ip' => false,
    'hostmanager_include_offline'   => true,
    'hostmanager_manage_guest'      => true,
    'hostmanager_manage_host'       => true,
    'memory'                        => 512,
    'provider'                      => 'virtualbox',
    'shell'                         => nil,
    'synced_directories'            => [],
    'user'                          => 'vagrant',
    'vms'                           => [{'name' => 'default', 'ip' => '192.168.123.123'}]
  }

  # merge overrides
  settings.merge!(overrides)

  # inherit global settings for undefined vm settings
  # using select to avoid inheriting certain keys
  #   - vms:  we don't want settings['vms']['vms']
  #   - shell: global shell setting defines a shell command that runs on all hosts
  #   - hostmanager*: hostmanager settings do not apply to vms
  vm_settings = settings.select {|k,v| k != 'vms' and k != 'shell' and not k.start_with?('hostmanager')}
  settings['vms'].map! {|vm| vm_settings.merge(vm)}

  return settings
end

# ===== SSH Config =====

def update_ssh_config(domain, vms)
  # setup variables
  ssh_config_path = ENV['HOME'] + '/.ssh/config'

  # assemble ssh config string
  ssh_start_msg = "## start vagrant managed config ##\n"
  ssh_end_msg = "## end vagrant managed config ##\n"
  ssh_hosts = "Host *#{domain}\n"\
    "  UserKnownHostsFile /dev/null\n"\
    "  StrictHostKeyChecking no\n"\
    "  PasswordAuthentication no\n"\
    "  IdentitiesOnly yes\n"\
    "  LogLevel FATAL\n"
  vms.each do |val|
    ssh_hosts += "Host #{val['name'] + domain}\n"\
      "  User #{val['user']}\n"\
      "  HostName #{val['ip']}\n"\
      "  IdentityFile #{Pathname.new(__FILE__).dirname}/.vagrant/machines/#{val['name']}/virtualbox/private_key\n"
  end
  ssh_config = ssh_start_msg + ssh_hosts + ssh_end_msg

  # create ~/.ssh/config
  if not File.exists?(ssh_config_path)
    File.new(ssh_config_path, 'w')
  end

  # check if ~/.ssh/config is currently managed by vagrant
  vagrant_managed_file = File.readlines(ssh_config_path).grep(ssh_start_msg).any?

  # append vagrant ssh config if it doesn't exist, or
  # overwrite existing vagrant ssh config
  if not vagrant_managed_file
    File.open(ssh_config_path, 'a') do |file|
      file.puts "\n" + ssh_config
    end
  else
    # open temp file for updating
    tmp_file = Tempfile.new('ssh_config-' + Time.now.to_i.to_s)
    begin
      File.open(ssh_config_path, 'r') do |file|
        vagrant_managed = false
        file.each_line do |line|
          if line == ssh_start_msg
            vagrant_managed = true
            tmp_file.puts ssh_config
            next
          elsif line == ssh_end_msg
            vagrant_managed = false
          elsif vagrant_managed == false
            tmp_file.puts line
          end
        end
      end
      tmp_file.close
      FileUtils.mv(tmp_file.path, ssh_config_path)
    ensure
      tmp_file.close
      tmp_file.unlink
    end
  end
end

# ===== Vagrant Config =====

# get dirname of Vagrantfile
dirname = Pathname.new(__FILE__).dirname

# load yaml vagrant config
vagrant_config = dirname + 'vagrant.yml'
if File.exists?(vagrant_config)
  settings = load_settings(YAML.load_file(vagrant_config))
else
  settings = load_settings({})
end

# update ssh config
update_ssh_config(settings['domain'], settings['vms'])

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

        # Use paravirtualized network in virtualbox for better performance
        # https://www.virtualbox.org/manual/ch06.html#nichardware
        if val['provider'] == 'virtualbox'
          vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
          vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
        end
      end

      # disable default synced folder
      item.vm.synced_folder ".", "/vagrant", disabled: settings['disable_default_synced_folder']

      # vm synced folders
      val['synced_directories'].each do |mnt|
        item.vm.synced_folder mnt['src'], mnt['dest'],
          owner: val['user'],
          group: val['user']
      end

      # vm shell commands
      item.vm.provision 'shell', inline: val['shell'] if val['shell']

      # run ansible on vm
      if val['ansible_playbook']
        item.vm.provision 'ansible' do |ansible|
          ansible.host_key_checking = false
          ansible.inventory_path    = dirname + val['ansible_inventory_path']
          ansible.limit             = val['ansible_limit']
          ansible.raw_arguments     = val['ansible_raw_arguments']
          ansible.extra_vars        = val['ansible_extra_vars']
          ansible.playbook          = val['ansible_playbook']
        end
      end
    end
  end
end
