require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_string = params.map do |key, _|
      "#{key} = ?"
    end.join(" AND ")
    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      WHERE
        #{where_string}
    SQL
    self.parse_all(results)
  end
end

class SQLObject
  extend Searchable
end
