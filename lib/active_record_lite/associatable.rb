require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'


class AssocParams
  def other_class
    @other_class_name.constantize
  end

  def other_table
    other_class.table_name
  end
end

class BelongsToAssocParams < AssocParams
  attr_reader :other_class_name, :primary_key, :foreign_key

  def initialize(name, params)
    @other_class_name = params[:class_name] || name.to_s.camelize
    @primary_key = params[:primary_key] || :id
    @foreign_key = params[:foreign_key] || "#{name}_id".to_sym
  end

  def type
    :belongs_to
  end
end

class HasManyAssocParams < AssocParams
  attr_reader :other_class_name, :primary_key, :foreign_key

  def initialize(name, params, self_class)
    @other_class_name = params[:class_name] || name.to_s.singularize.camelize
    @primary_key = params[:primary_key] || :id
    @foreign_key = params[:foreign_key] || "#{self_class}_id".underscore
  end

  def type
    :has_many
  end
end



module Associatable
  def assoc_params
    @assoc_params ||= {}
    @assoc_params
  end

  def belongs_to(name, params = {})
    params = BelongsToAssocParams.new(name, params)
    assoc_params[name] = params

    define_method(name) do
      query = <<-SQL
        SELECT  *
        FROM    #{params.other_table}
        WHERE   #{params.other_table}.#{params.primary_key} = ?
      SQL
      params.other_class.parse_all(DBConnection.execute(query, self.send(params.foreign_key)))
    end
  end

  def has_many(name, params = {})
    params = HasManyAssocParams.new(name, params, self)
    assoc_params[name] = params

    define_method(name) do
      query = <<-SQL
        SELECT  *
        FROM    #{params.other_table}
        WHERE   #{params.other_table}.#{params.foreign_key} = ?
      SQL
      params.other_class.parse_all(DBConnection.execute(query, self.send(params.primary_key)))
    end
  end

  def has_one_through(name, assoc1, assoc2)
    define_method(name) do
      a1_params = self.class.assoc_params[assoc1]
      a2_params = a1_params.other_class.assoc_params[assoc2]

      query = <<-SQL
        SELECT  #{a2_params.other_table}.*
        FROM    #{a2_params.other_table}
        JOIN    #{a1_params.other_table}
        ON      #{a2_params.other_table}.#{a2_params.primary_key} = #{a1_params.other_table}.#{a2_params.foreign_key}
        WHERE   #{a1_params.other_table}.#{a1_params.primary_key} = ?
      SQL

      a2_params.other_class.parse_all(DBConnection.execute(query, self.send(a1_params.foreign_key)))
    end
  end
end
