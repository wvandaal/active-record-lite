require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'
require 'active_support/inflector'


class SQLObject < MassObject
  extend Searchable, Associatable

  def self.set_table_name(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.underscore
  end

  def self.all
    query = <<-SQL
      SELECT  *
      FROM    "#{@table_name}"
    SQL
    parse_all(DBConnection.execute(query))
  end

  def self.find(id)
    query = <<-SQL
      SELECT  *
      FROM    "#{@table_name}"
      WHERE   id = ?
    SQL
    parse_all(DBConnection.execute(query, id)).first
  end

  def save
    self.id.nil? ? create : update
  end

  private

  def create
    attr_string = self.class.attributes.join(', ')
    wildcard_string = (['?'] * self.class.attributes.count).join(', ')
    query = <<-SQL
      INSERT INTO  #{self.class.table_name} (#{attr_string}) 
      VALUES      (#{wildcard_string})
    SQL
    DBConnection.execute(query, *attribute_values)

    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_str = self.class.attributes.map {|attr| "#{attr} = ?"}.join(', ')
    query = <<-SQL
      UPDATE  #{self.class.table_name}
      SET     #{set_str}
      WHERE   id = ?
    SQL
    DBConnection.execute(query, self.id)
  end


  def attribute_values
    self.class.attributes.map {|attr| self.send(attr)}
  end
end
