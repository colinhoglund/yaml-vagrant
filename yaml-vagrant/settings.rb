require 'yaml'

class Settings
  attr_reader :settings

  def initialize(settings)
    # load settings hash
    @settings = settings
    # set undefined defaults
    set_defaults(YAML.load_file('yaml-vagrant/defaults.yml'))
  end

  def self.build(settings)
    return new(settings).settings
  end

  private
  def set_defaults(defaults)
    # set base defaults where not defined
    defaults.each do |k,v|
      @settings[k] ||= v
    end
    # set vm defaults where not defined
    @settings['vms'].each do |vm|
      defaults['vms'].each do |k,v|
        vm[k] ||= v
      end
    end
  end
end
