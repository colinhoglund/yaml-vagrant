# yaml-vagrant
Define Vagrant configuration with YAML.

The key components of yaml-vagrant are:
- [Vagrantfile](https://github.com/colinhoglund/yaml-vagrant/blob/master/Vagrantfile): A generic Vagrantfile that configures machines based on the vagrant.yml configuration.
- vagrant.yml: This is where all of your environment specific configuration lives. This file should exist in the same directory as the Vagrantfile.

By default, yaml-vagrant handles updating the user's local ~/.ssh/config. It also enables the [vagrant-hostmanager](https://github.com/devopsgroup-io/vagrant-hostmanager) plugin to maintain a consistent /etc/hosts file across your workstation and all VMs. In order to update /etc/hosts, it will ask for your password when provisioning VMs.

## Requirements
- [Vagrant](https://www.vagrantup.com/docs/installation/)
- [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
- [vagrant-hostmanager](https://github.com/devopsgroup-io/vagrant-hostmanager)

## Ansible
yaml-vagrant works with the Ansible provisioner using the contained dynamic inventory script ([vagrant.py](https://github.com/colinhoglund/yaml-vagrant/blob/master/extras/vagrant.py)). This allows you to define ansible settings and call ansible playbooks for vagrant VMs.
