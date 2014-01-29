require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    results.map { |result| self.new(result) }
  end
end

class SQLObject < MassObject
  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.underscore.pluralize
  end

  def self.all
    all = DBConnection.execute(<<-SQL)
    SELECT 
      *
    FROM 
      "#{table_name}"
    SQL
    
    all.map { |result| self.new(result) }
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
    SELECT 
      *
    FROM
      "#{table_name}"
    WHERE
      id = ?
    SQL
    
    return self.new(result.first) unless result.empty?
    nil
  end

  def insert
    # ...
    attr_names = self.class.attributes.join(", ")
    q_marks = (["?"] * self.class.attributes.count).join(", ")
    
    DBConnection.execute(<<-SQL, *self.attribute_values)
    INSERT INTO
      #{self.class.table_name} (#{attr_names})
    VALUES
      (#{q_marks})
    
    SQL
    self.id = DBConnection.last_insert_row_id  
  end

  def save
    if self.id.nil?
      self.insert
    else
      self.update
    end
  end

  def update
    set_line_arr = self.class.attributes.map { |attribute| "#{attribute} = ?"}
    set_line = set_line_arr.join(", ")
    
    DBConnection.execute(<<-SQL, *attribute_values, self.id)
    UPDATE
      "#{self.class.table_name}"
    SET
      #{set_line}
    WHERE
      id = ?
    SQL
    
    puts "Saved"
  end

  def attribute_values
    self.class.attributes.map do |attribute|
      send("#{attribute}")
    end
  end
end
