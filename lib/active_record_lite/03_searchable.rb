require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable
  def where(params)
    # ...
    where_param_arr = params.keys.map { |key| "#{key} = ?"}
    where_param = where_param_arr.join(" AND ")
    values = params.values
    
    results = DBConnection.execute(<<-SQL, *values)
    SELECT
      *
    FROM
      #{table_name}
    WHERE
      #{where_param}
    SQL
    
    results.map { |result| self.new(result) }
  end
end

class SQLObject
  extend Searchable
end
