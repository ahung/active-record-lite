require_relative '00_attr_accessor_object.rb'

class MassObject < AttrAccessorObject
  def self.my_attr_accessible(*new_attributes)
    new_attributes.each do |new_attribute|
      self.attributes << new_attribute
    end
  end

  def self.attributes
    if self == MassObject
      raise "must not call #attributes on MassObject directly"
    end
    @attributes ||= []
  end

  def initialize(params = {})
    params.each do |attr_name, attr_val|
      if self.class.attributes.include?(attr_name.to_sym)
        send("#{attr_name}=", attr_val)
      else
        raise "mass assignment to unregistered attribute '#{attr_name}'"
      end
    end
  end
end
