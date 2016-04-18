class SSHConfig
  def initialize(domain, hosts)
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
  end
end
