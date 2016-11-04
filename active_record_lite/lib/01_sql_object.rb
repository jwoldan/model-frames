require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    if @columns.nil?
      result = DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          #{table_name}
      SQL
      @columns = result[0].map(&:to_sym)
    end
    @columns
  end

  def self.finalize!
    columns.each do |column|
      define_method(column) do
        attributes[column]
      end
      define_method("#{column.to_s}=") do |val|
        attributes[column] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL
    parse_all(results)
  end

  def self.parse_all(results)
    results.map do |row|
      self.new(row)
    end
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    params.each do |key, value|
      key = key.to_sym unless key.is_a? Symbol
      if self.class.columns.include?(key)
        self.send("#{key}=", value)
      else
        raise "unknown attribute '#{key}'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
