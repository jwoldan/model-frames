require_relative 'db_connection'
require 'active_support/inflector'

class ModelObject

  def self.columns
    if @columns.nil?
      result = DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          #{table_name}
        LIMIT
          1
      SQL
      @columns = result[0].map(&:to_sym)
    end
    @columns
  end

  # ModelObject#finalize! creates an attribute reader and writer for each column
  # self.finalize! should be called at the end of the the subclass definition.
  def self.finalize!
    columns.each do |column|
      define_method(column) do
        attributes[column]
      end
      define_method("#{column}=") do |val|
        attributes[column] = val
      end
    end
  end

  # Used to override the default table name.
  # Should only be called in the subclass definition, and only once!
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
    results = DBConnection.execute(<<-SQL, id)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL
    parse_all(results).first
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
    self.class.columns.map { |column| self.send(column) }
  end

  def save
    self.id.nil? ? insert : update
  end

  private

  def insert
    columns = self.class.columns
    column_names = columns.join(", ")
    question_marks = (["?"] * columns.count).join(", ")
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{column_names})
      VALUES
        (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    column_setters = self.class.columns.map do |column|
      "#{column} = ?"
    end.join(", ")
    DBConnection.execute(<<-SQL, *attribute_values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{column_setters}
      WHERE
        id = ?
    SQL
  end

end
