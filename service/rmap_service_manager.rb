require 'yaml'
require 'require_relative'

require_relative '../logging'
require_relative '../datasource/datasource_arcgis_cache'
require_relative '../datasource/util'

class RMapServiceManager
  @port = 9494
  @host = "127.0.0.1"
  @services = {}
  @port_entities = {}

  class << self; attr_accessor :port, :host, :services, :port_entities end

  def self.register_services
    unless File.exist?("./services.yml")
      "Service config file does not exist!"
    end
    config = YAML.load_file("./services.yml")
    @port = config["port"]
    @host = config["host"]
    config["services"].each_pair do |k,v|
      @services[k] =  DataSourceArcgisCache.new(v)
    end
  end
end
