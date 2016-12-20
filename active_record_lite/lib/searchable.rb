require_relative 'db_connection'
require_relative 'model_object'
require_relative 'model_relation'

module Searchable

  def where(params)
    ModelRelation.new(self).where(params)
  end

  protected

  def where_exec(criteria)
    where_values = []
    where_string = criteria[:where].map do |cond|
      if cond.is_a? String
        cond
      else
        where_values << cond[1]
        "#{cond[0]} = ?"
      end
    end.join(" AND ")

    # helper methods to create portions of the query
    # note that these use string interpolation so they
    # are somewhat unsafe
    select_string = create_select_string(criteria[:select])
    limit_string = create_limit_string(criteria[:limit])
    order_string = create_order_string(criteria[:order])

    sql_query = <<-SQL
      SELECT
        #{select_string}
      FROM
        #{self.table_name}
      WHERE
        #{where_string}
      #{order_string}
      #{limit_string}
    SQL
    results = DBConnection.execute(sql_query, where_values)
    self.parse_all(results)
  end

  def create_select_string(select_string)
    if select_string.nil?
      "#{self.table_name}.*"
    else
      select_string
    end
  end

  def create_limit_string(limit)
    if limit.nil? || !(limit.is_a? Integer)
      ""
    else
      "LIMIT #{limit}"
    end
  end

  def create_order_string(order)
    if order.nil? || order.empty?
      ""
    else
      "ORDER BY #{order}"
    end
  end

end
