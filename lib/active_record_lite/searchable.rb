require_relative './db_connection'

module Searchable
  def where(params)
  	where_clause = params.keys.map {|k| "#{k} = ?"}.join(' AND ')
  	query = <<-SQL
  		SELECT 	*
  		FROM		#{table_name}
  		WHERE 	#{where_clause}
  	SQL
  	parse_all(DBConnection.execute(query, *params.values))
  end
end