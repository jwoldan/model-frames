require_relative '03_associatable'

module Associatable
  def has_one_through(name, through_name, source_name)
    through_options = self.assoc_options[through_name]
    through_table = through_options.model_class.table_name

    define_method(name) do
      source_options =
        through_options.model_class.assoc_options[source_name]
      source_table = source_options.model_class.table_name

      result = DBConnection.execute(<<-SQL)
        SELECT
          #{source_table}.*
        FROM
          #{source_table}
        JOIN
          #{through_table}
        ON
          #{through_table}.#{source_options.foreign_key}
          = #{source_table}.#{source_options.primary_key}
        WHERE
          #{through_table}.#{through_options.primary_key}
          = #{self.send(through_options.foreign_key)}
      SQL
      source_options.model_class.parse_all(result).first
    end
  end
end
