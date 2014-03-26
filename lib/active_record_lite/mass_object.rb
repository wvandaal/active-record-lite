class MassObject
  def self.set_attrs(*attributes)
  	@attributes = attributes

  	@attributes.each do |attribute|
  		attr_accessor attribute
  	end
  end

  def self.attributes
  	@attributes
  end

  def self.parse_all(results)
  	results.map {|result| self.new(result)}
  end

  def initialize(params = {})
  	params.each do |key, val|
  		key = key.to_sym
  		if self.class.attributes.include?(key)
  			self.send("#{key}=", val)
  		else
  			raise "mass assignment to unregistered attribute #{key}"
  		end
  	end
  end
end
