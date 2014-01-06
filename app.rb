require 'sinatra'
require 'base64'
require 'require_relative'
require_relative './datasource/datasource_arcgis_cache'
require_relative './datasource/util'
require_relative './service/rmap_service_manager'
RMapServiceManager.register_services
set :port, RMapServiceManager.port

get '/:service_name' do
  @service_address = "http://%s:%s/RMS/rest/services/%s/MapServer" % [ RMapServiceManager.host, RMapServiceManager.port, params[:service_name]]
  erb :index 
end

get '/RMS/rest/services/:servicename/MapServer' do
  unless RMapServiceManager.services.include?(params[:servicename])
    "Service : #{params[:servicename]} does not start!"
    return
  end
  ds = RMapServiceManager.services[params[:servicename]]
  unless params[:f].nil?
    case params[:f]
    when "json"
      if params[:callback]
        "#{params[:callback]}(#{ds.tiling_scheme.rest_response_arcgis_json})"
      end   
      when "pjson"
        if params[:callback]
        "#{params[:callback]}(#{ds.tiling_scheme.rest_response_arcgis_pjson})"
        end
    when "jsapi"
      @service_address = "http://%s:%s/RMS/rest/services/%s/MapServer" % [ RMapServiceManager.host, RMapServiceManager.port, params[:servicename]]
      erb :index 
    else
      "Only suport json/pjson/jsapi format!"
    end   
  end
end

get '/RMS/rest/services/:service_name/MapServer/tile/:level/:row/:col' do
  headers 'Content-Type' => "image/png"
  unless RMapServiceManager.services.include?(params[:service_name])
    "Service : #{params[:service_name]} does not start!"
    return
  end

  ds = RMapServiceManager.services[params[:service_name]]
  ds.get_tile_bytes(params[:level].to_i,params[:row].to_i,params[:col].to_i) 
end

#===========================TEST==========================
get '/' do
  stream do |out|
    out << "It's gonna be legen -\n"
    sleep 0.5
    out << " (wait for it) \n"
    sleep 1
    out << "- dary!\n"
  end
end

get '/evented' do
  stream(:keep_open) do |out|
    EventMachine::PeriodicTimer.new(1) { out << "#{Time.now}\n" }
  end
end

get '/png' do
  send_file '32747.png'
end


