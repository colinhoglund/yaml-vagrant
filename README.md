# yaml-vagrant
Define Vagrant configuration with YAML.

The key components of yaml-vagrant are:
- [vagrant.yml](https://github.com/colinhoglund/yaml-vagrant/blob/master/vagrant.yml): This is where all of your environment specific configuration lives.
- [Vagrantfile](https://github.com/colinhoglund/yaml-vagrant/blob/master/Vagrantfile): A generic Vagrantfile that configures machines based on the vagrant.yml configuration.

By default, yaml-vagrant handles updating the user's local ~/.ssh/config. It also enables the [vagrant-hostmanager](https://github.com/devopsgroup-io/vagrant-hostmanager) plugin to maintain a consistent /etc/hosts file across your workstation and all VMs. In order to update /etc/hosts, it will ask for your password when provisioning VMs.

## Requirements
- [Vagrant](https://www.vagrantup.com/docs/installation/)
- [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
- [vagrant-hostmanager](https://github.com/devopsgroup-io/vagrant-hostmanager)
- [Ansible](http://docs.ansible.com/ansible/intro_installation.html) (If running example code that uses Ansible)

## Ansible
yaml-vagrant works with the Ansible provisioner using the contained dynamic inventory script ([vagrant.py](https://github.com/colinhoglund/yaml-vagrant/blob/master/vagrant.py)). This allows you to define ansible settings and call ansible playbooks for vagrant VMs, as shown in [vagrant.yml](https://github.com/colinhoglund/yaml-vagrant/blob/master/vagrant.yml).

## Example
This example is not very well thought out and is mainly for showcasing some of the parameters allowed in [vagrant.yml](https://github.com/colinhoglund/yaml-vagrant/blob/master/vagrant.yml).

The following steps will run the example configuration which does the following:
- Updates ~/.ssh/config
- Sets up two VMs (web and db) according to [vagrant.yml](https://github.com/colinhoglund/yaml-vagrant/blob/master/vagrant.yml)
- Updates /etc/hosts on workstation and VMs
- Runs example shell scripts on the VMs
- Installs packages to VMs using Ansible
```
git clone git@github.com:colinhoglund/yaml-vagrant.git
cd yaml-vagrant/
vagrant up
# Type workstation password when prompted to update /etc/hosts
```
