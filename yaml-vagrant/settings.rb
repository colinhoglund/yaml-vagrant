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
    # set all defaults
    defaults['all'].each do |k,v|
      @settings[k] ||= v
      # set vm defaults
      @settings['vms'].each do |vm|
        vm[k] ||= @settings[k]
      end
    end
    # set base only defaults
    defaults['base'].each do |k,v|
      @settings[k] ||= v
    end
  end
end
