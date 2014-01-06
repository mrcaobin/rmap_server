class DataSourceBase
	attr_accessor :type, :path, :tiling_scheme
  
  def initialize(path)
		@path = path
	end
end
