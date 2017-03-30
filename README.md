# yaml-vagrant
Define Vagrant configuration with YAML.

The key components of yaml-vagrant are:
- [Vagrantfile](https://github.com/colinhoglund/yaml-vagrant/blob/master/Vagrantfile): A generic Vagrantfile that configures machines based on the vagrant.yml configuration.
- vagrant.yml: This is where all of your environment specific configuration lives. This file should exist in the same directory as the Vagrantfile.

By default, yaml-vagrant handles updating the user's local ~/.ssh/config. It also enables the [vagrant-hostmanager](https://github.com/devopsgroup-io/vagrant-hostmanager) plugin to maintain a consistent /etc/hosts configuration across your workstation and all VMs. In order to update /etc/hosts, you will be asked for your password when provisioning VMs.

## Requirements
- [Vagrant](https://www.vagrantup.com/docs/installation/)
- [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
- [vagrant-hostmanager](https://github.com/devopsgroup-io/vagrant-hostmanager)

## Ansible
yaml-vagrant works with the Ansible provisioner using the contained dynamic inventory script ([vagrant.py](https://github.com/colinhoglund/yaml-vagrant/blob/master/vagrant.py)). This allows you to define ansible settings and call ansible playbooks for vagrant VMs.

## Usage
The following examples give an idea of what a vagrant.yml file looks like. Once the vagrant.yml file has been created, you can use vagrant like you normally would (`vagrant status`, `vagrant up app`, etc.)

Example vagrant.yml:

    ---

    ## base config

    # default box
    box: ubuntu/trusty64
    # local dev domain
    domain: .local
    # generic shell script to run on all hosts
    shell: |
      sudo apt-get remove -y puppet* chef*

    ## vm specific config

    vms:
      - name: app
        ip: 192.168.10.10
        # DNS aliases for local /etc/hosts (app.local, www.local)
        aliases: [ app, www ]
        # sync workstation src directory to VM dest directory
        synced_directories:
          - { src: ~/code/app, dest: /srv/app }

      - name: db
        ip: 192.168.10.11
        aliases: [ db ]

Example vagrant.yml using the Ansible provisioner:

    ---

    box: ubuntu/trusty64
    domain: .local
    shell: |
      sudo apt-get remove -y puppet* chef*

    ansible_inventory_path: inventory/vagrant.py

    vms:
      - name: app
        memory: 1536
        ip: 192.168.10.10
        aliases: [ app, www ]
        synced_directories:
          - { src: ~/code/app, dest: /srv/app }
        ansible_playbook: site.yml
        ansible_limit: app
        ansible_groups: [ app ]
