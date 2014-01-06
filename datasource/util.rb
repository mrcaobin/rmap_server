module Util
  datasource_type = %w[
    MBTiles, 
    ArcGISCache
  ]
  image_format = %w[
    PNG, 
    PNG32,
    PNG24,
    PNG8,
    JPG,
    JPEG,
    MIXED
  ]
  storage_format = %w[
    esriMapCacheStorageModeExploded,
    esriMapCacheStorageModeCompact,
    unknown
  ]
  tile_generated_source = %w[
    DynamicOutput,
    FromMemcached,
    FromFileCache
  ]
end

class LodInfo
  attr_accessor :level_id, :scale, :resolution
end
