require 'require_relative'
require_relative 'envelope'

class Point
	attr_accessor :ext, :x, :y

	def initialize(x,y)
		@x=x
		@y=y
	end

	public
	def extent
		if ext.nil?
			ext = Envelope.new(@x,@y,@x,@y)
			return ext
		end
	end
end
