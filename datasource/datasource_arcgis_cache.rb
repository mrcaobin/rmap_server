require 'rexml/document'
require 'json'
require 'base64'
require 'require_relative'
require 'debugger'
require_relative '../logging'
require_relative '../geometry/point'
require_relative '../geometry/envelope'
require_relative 'datasource_base'
require_relative 'util'
require_relative 'tiling_scheme'

class DataSourceArcgisCache < DataSourceBase
  include Logging
  include REXML 
  include Util 

  def initialize(path)
    if Dir.exist?(path) && Dir.exist?("#{path}/Layers")
      super(path)
      @type = "ArcGISCache" 
      init_tiling_scheme
      process_tiling_scheme
    else
      logger.error 'DataSourceArcgisCache::Initialize path does not exist'
    end 
  end

  def init_tiling_scheme
    if path.nil?
      logger.error 'DataSourceArcgisCache::InitTilingScheme path is nil'
    end
    logger.info "Start initialize datasource config file..."
    logger.info "Path -> #{@path}"
    logger.info "Type -> #{@type}"
    @tiling_scheme = TilingScheme.new()
    @tiling_scheme.path = path
    doc = Document.new(File.new("#{@path}/Layers/Conf.xml"))  
    @tiling_scheme.wkt =  doc.elements["CacheInfo/TileCacheInfo/SpatialReference/WKT"].text
    logger.info "WKT -> #{@tiling_scheme.wkt}"
    @tiling_scheme.wkid=-1
    unless  doc.elements["CacheInfo/TileCacheInfo/SpatialReference/WKID"].nil?
      @tiling_scheme.wkid =  doc.elements["CacheInfo/TileCacheInfo/SpatialReference/WKID"].text.to_i
    end
    logger.info "WKID -> #{@tiling_scheme.wkid}"
    @tiling_scheme.tile_origin = Point.new(doc.elements["CacheInfo/TileCacheInfo/TileOrigin/X"].text.to_f,doc.elements["CacheInfo/TileCacheInfo/TileOrigin/Y"].text.to_f)
    @tiling_scheme.dpi = doc.elements["CacheInfo/TileCacheInfo/DPI"].text.to_i
    logger.info "DPI -> #{@tiling_scheme.dpi}"
    @tiling_scheme.lods = []
    @tiling_scheme.lods_json = []
    doc.elements["CacheInfo/TileCacheInfo/LODInfos"].each do |e|
      lod = LodInfo.new 
      lod.level_id = e.elements["LevelID"].text.to_i
      lod.scale = e.elements["Scale"].text.to_f
      lod.resolution = e.elements["Resolution"].text.to_f
      @tiling_scheme.lods.push(lod)
      @tiling_scheme.lods_json.push({:level=>lod.level_id,:resolution=>lod.resolution,:scale=>lod.scale})
    end
    logger.info "lods -> #{@tiling_scheme.lods_json.to_json}"
    @tiling_scheme.tile_cols = doc.elements["CacheInfo/TileCacheInfo/TileCols"].text.to_i 
    logger.info "cols -> #{@tiling_scheme.tile_cols}"
    @tiling_scheme.tile_rows = doc.elements["CacheInfo/TileCacheInfo/TileRows"].text.to_i
    logger.info "rows -> #{@tiling_scheme.tile_rows}"
    @tiling_scheme.cache_tile_format = doc.elements["CacheInfo/TileImageInfo/CacheTileFormat"].text
    logger.info "CacheTileFormat -> #{@tiling_scheme.cache_tile_format}"
    @tiling_scheme.compression_quality = doc.elements["CacheInfo/TileImageInfo/CompressionQuality"].text.to_i
    @tiling_scheme.storage_format = doc.elements["CacheInfo/CacheStorageInfo/StorageFormat"].text
    logger.info "Storage_format -> #{@tiling_scheme.storage_format}"
    @tiling_scheme.packet_size = doc.elements["CacheInfo/CacheStorageInfo/PacketSize"].text.to_i
    doc = Document.new(File.new("#{@path}/Layers/conf.cdi"))
    xmin = doc.elements["EnvelopeN/XMin"].text
    xmax = doc.elements["EnvelopeN/XMax"].text  
    ymin = doc.elements["EnvelopeN/YMin"].text
    ymax = doc.elements["EnvelopeN/YMax"].text
    @tiling_scheme.full_extent = Envelope.new(xmin.to_f,ymin.to_f,xmax.to_f,ymax.to_f)
    @tiling_scheme.initial_extent = Envelope.new(xmin.to_f,ymin.to_f,xmax.to_f,ymax.to_f)
  end

  def process_tiling_scheme
    ts = @tiling_scheme
    post={}
    post["currentVersion"] = 10.1
    post["serviceDescription"] = "This service is published by RMapServer by Caobin(shsmi)."
    post["mapName"] = "Layers"
    post["description"] = "none"
    post["copyrightText"] = "RMS by Caobin(shsmi)."
    layers = []
    layer = {
      "id" => 0,
      "name" => "YourServiceNameHere", 
      "parentLayerId" => -1, 
      "defaultVisibility"=> true,
      "subLayerIds" => nil,
      "minScale" => 0,
      "maxScale" => 0
    }
    layers.push(layer)
    post["layers"] = layers
    tables=[]
    post["tables"] = []
    post["spatialReference"] = { "wkid" =>ts.wkid }
    post["singleFusedMapCache"] = true
    post["tileInfo"] = {
      "rows" => ts.tile_rows, 
      "cols" => ts.tile_cols, 
      "dpi" => ts.dpi, 
      "format" => ts.cache_tile_format, 
      "compression_quality" => ts.compression_quality, 
      "origin" => { 
        "x" => ts.tile_origin.x, 
        "y" => ts.tile_origin.y
      },
      "spatialReference" => { "wkid" => ts.wkid },
      "lods" => ts.lods_json
    }
    post["initialExtent"] = {
      "xmin" => ts.initial_extent.x_min,
      "ymin" => ts.initial_extent.y_min,
      "xmax" => ts.initial_extent.x_max,
      "ymax" => ts.initial_extent.y_max,
      "spatialReference"=> { "wkid" => ts.wkid }
    }
    post["fullExtent"] = {
      "xmin" => ts.full_extent.x_min,
      "ymin" => ts.full_extent.y_min,
      "xmax" => ts.full_extent.x_max,
      "ymax" => ts.full_extent.y_max,
      "spatialReference" => { "wkid"=>ts.wkid }
    }
    post["units"] = "esriMeters"
    post["supportedImageFormatType"] = "PNG24,PNG,JPG,DIB,TIFF,EMF,PS,PDF,GIF,SVG,SVGZ,AI,BMP"
    post["documentInfo"] = {
      "Title" => "none",
      "Author" => "none",
      "Comments" => "none",
      "Subject" => "none",
      "Category" => "none",
      "Keywords" => "none",
      "Credits" => "Caobin"
    }
    post["capabilities"] = "Map,Query,Data"
    ts.rest_response_arcgis_json = post.to_json
    ts.rest_response_arcgis_pjson = post.to_json
    @tiling_scheme = ts
  end


  def get_tile_bytes(level,row,col)
    if @tiling_scheme.storage_format == "esriMapCacheStorageModeExploded"
      base_url = @tiling_scheme.path
      suffix = @tiling.cache_tile_format.upcase.include?("PNG") ? "png" : "jpg"
      row_index = (row/@tiling_scheme.packet_size)*@tiling_scheme.packet_size
      col_index = (col/@tiling_scheme.packet_size)*@tiling_scheme.packet_size
      filename = "%s/Layers/_alllayers/L%02d/R%08x/C%08x.%s" % [baseurl,level,row_index,col_index,suffix]
      if byte_path.nil? || !File.exist(base_path)
        return nil
      end
      File.new(filename) do |f|
        img_data = f.read(byte_path)
      end
      return img_data
    else
      row_index = (row/@tiling_scheme.packet_size)*@tiling_scheme.packet_size
      col_index = (col/@tiling_scheme.packet_size)*@tiling_scheme.packet_size

      record_size = 5
      base_url= @tiling_scheme.path
      filename = "%s/Layers/_alllayers/L%02d/R%04xC%04x" % [base_url,level,row_index,col_index]
      bundlx = "%s.bundlx" % filename
      bundle = "%s.bundle" % filename
      record_number = @tiling_scheme.packet_size*(col-col_index) + (row - row_index)
      if record_number < 0
        logger.error "Invalid level/row/col"
      end
      offset = 16 + record_number * record_size
      idx_data = []
      File.open(bundlx) do |f|
        f.seek(offset)
        idx_data = f.read(5).bytes
      end
      bundle_offset = ((idx_data[4] & 0xFF) << 32) |((idx_data[3] & 0xFF) << 24) | ((idx_data[2] & 0xFF) << 16) | ((idx_data[1] & 0xFF) << 8) | (idx_data[0] & 0xFF)
      File.open(bundle) do |f|
        f.seek(bundle_offset)
        buffer = f.read(4).bytes
        record_len = ((buffer[3] & 0xFF) << 24) | ((buffer[2] & 0xFF) << 16) | ((buffer[1] & 0xFF) << 8) | (buffer[0] & 0xFF)
        return  f.read(record_len)
      end
    end 
  end
end
