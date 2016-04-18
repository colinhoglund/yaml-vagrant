require 'yaml'

class Settings
  def initialize(settings)
    @settings = settings
    set_defaults(YAML.load_file('yaml-vagrant/defaults.yml'))
  end

  def self.build(settings)
    return new(settings).settings
  end

  attr_reader :settings

  private
  def set_defaults(defaults)
    defaults.each do |k,v|
      @settings[k] ||= v
    end
    @settings['vms'].each do |vm|
      defaults['vm'].each do |k,v|
        vm[k] ||= v
      end
    end
    @settings.delete('vm')
  end
end
