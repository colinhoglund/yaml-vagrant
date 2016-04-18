# yaml-vagrant
Define Vagrant configuration with YAML.

The key components of yaml-vagrant are:
- **vagrant.yml**: This is where all of your environment specific configuration lives.
- **Vagrantfile**: A generic Vagrantfile that configures machines based on the vagrant.yml configuration. By default, this file also handles updating the user's ~/.ssh/config and /etc/hosts.
