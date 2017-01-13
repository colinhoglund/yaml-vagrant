require 'pathname'
require 'yaml'

class Settings
  attr_reader :settings

  def initialize(settings)
    # load settings hash
    @settings = settings
    # set undefined defaults
    set_defaults(YAML.load_file(Pathname.new(__FILE__).dirname + 'settings.yml'))
  end

  def self.build(settings)
    return new(settings).settings
  end

  private
  def set_defaults(defaults)
    # set base only defaults
    defaults['base'].each do |k,v|
      if not @settings.key?(k)
        @settings[k] = v
      end
    end
    # set all defaults
    defaults['all'].each do |k,v|
      if not @settings.key?(k)
        @settings[k] = v
      end
      # set vm defaults
      @settings['vms'].each do |vm|
        if not vm.key?(k)
          vm[k] = v
        end
      end
    end
  end
end
