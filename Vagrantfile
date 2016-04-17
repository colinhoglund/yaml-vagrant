# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'fileutils'
require 'pathname'
require 'tempfile'
require 'yaml'

Vagrant.configure(2) do |config|
  # get dirname of Vagrantfile
  dirname = Pathname.new(__FILE__).dirname

  # load yaml vagrant config
  yaml_conf = YAML.load_file(dirname + 'vagrant.yml')
  yaml_conf.each do |key, val|
    instance_variable_set("@#{key}", val)
  end

  # vagrant defaults
  @box                           ||= 'base'
  @disable_default_synced_folder ||= true
  @domain                        ||= '.local'
  @memory                        ||= 512
  @provider                      ||= 'virtualbox'
  @shell                         ||= nil
  @vms                           ||= []

  # hostmanager defaults
  @hostmanager_enabled           ||= true
  @hostmanager_ignore_private_ip ||= false
  @hostmanager_include_offline   ||= true
  @hostmanager_manage_guest      ||= true
  @hostmanager_manage_host       ||= true

  # ansible defaults
  @ansible_extra_vars     ||= {}
  @ansible_inventory_path ||= 'vagrant.py'
  @ansible_raw_arguments  ||= ''

  # build vagrant ssh config
  ssh_start_msg    = "## start vagrant managed config ##\n"
  ssh_end_msg      = "## end vagrant managed config ##\n"
  ssh_hosts = "Host *#{@domain}\n"\
    "  User vagrant\n"\
    "  UserKnownHostsFile /dev/null\n"\
    "  StrictHostKeyChecking no\n"\
    "  PasswordAuthentication no\n"\
    "  IdentitiesOnly yes\n"\
    "  LogLevel FATAL\n"
  @vms.each do |val|
    ssh_hosts += "Host #{val['name'] + @domain}\n"\
      "  HostName #{val['ip']}\n"\
      "  IdentityFile #{dirname}/.vagrant/machines/#{val['name']}/virtualbox/private_key\n"
  end
  ssh_config = ssh_start_msg + ssh_hosts + ssh_end_msg

  # update ~/.ssh/config
  ssh_config_path      = ENV['HOME'] + '/.ssh/config'
  vagrant_managed_file = File.readlines(ssh_config_path).grep(ssh_start_msg).any?

  # append vagrant ssh config if it doesn't exist
  if not vagrant_managed_file
    File.open(ssh_config_path, 'a') do |file|
      file.puts "\n" + ssh_config
    end
  else # overwrite existing vagrant ssh config
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

  # hostmanager config
  if @hostmanager_enabled
    config.hostmanager.enabled           = @hostmanager_enabled
    config.hostmanager.ignore_private_ip = @hostmanager_ignore_private_ip
    config.hostmanager.include_offline   = @hostmanager_include_offline
    config.hostmanager.manage_guest      = @hostmanager_manage_guest
    config.hostmanager.manage_host       = @hostmanager_manage_host
  end

  # disable default synced folder
  config.vm.synced_folder ".", "/vagrant", disabled: @disable_default_synced_folder

  # base shell commands
  config.vm.provision 'shell', inline: @shell if @shell

  # configure VMs
  @vms.each do |val|
    # vm vagrant defaults
    hostname                  = val['name'] + @domain
    val['aliases']            ||= [hostname]
    val['application_user']   ||= 'vagrant'
    val['box']                ||= @box
    val['memory']             ||= @memory
    val['provider']           ||= @provider
    val['shell']              ||= nil
    val['synced_directories'] ||= []

    # vm ansible defaults
    val['ansible_extra_vars']     ||= @ansible_extra_vars
    val['ansible_inventory_path'] ||= @ansible_inventory_path
    val['ansible_playbook']       ||= nil
    val['ansible_raw_arguments']  ||= @ansible_raw_arguments

    # vm settings
    config.vm.define val['name'] do |item|
      item.vm.box              = val['box']
      item.vm.hostname         = hostname
      item.hostmanager.aliases = val['aliases'].collect { |a| a + @domain } if @hostmanager_enabled

      # vm network config
      item.vm.network 'private_network', ip: val['ip']

      # vm provider and resource settings
      item.vm.provider val['provider'] do |vb|
        vb.memory = val['memory']
      end

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
