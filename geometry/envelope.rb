class Envelope 
	attr_accessor :extent, :x_min, :x_max, :y_min, :y_max 

	def initialize(xmin,ymin,xmax,ymax)
		@x_min = xmin
		@y_min = ymin
		@x_max = xmax
		@y_max = ymax
	end

	def union(newExtent)
		return Envelope.new(
      [@x_min,newExtent.x_min].min, 
			[@y_min,newExtent.y_min].min,
			[@x_max,newExtent.x_max].max,
			[@y_max,newExtent.y_max].max
    )
	end
end
