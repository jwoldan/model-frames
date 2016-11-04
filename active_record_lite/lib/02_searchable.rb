require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    Relation.new(self).where(params)
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
    if order.nil? || order.length == 0
      ""
    else
      "ORDER BY #{order}"
    end
  end

end

# Lazy loading and caching of query parts based on
# http://jeffkreeftmeijer.com/2011/method-chaining-and-lazy-evaluation-in-ruby/
class Relation
  include Enumerable

  def initialize(klass)
    @klass = klass
    @cached_exec = nil
  end

  def criteria
    @criteria ||= { where: [] }
  end

  def where(params)
    # if we change any query parameters, delete any cached results
    @cached_exec = nil

    if params.is_a? String
      criteria[:where] << params
    else
      params.map do |key, val|
        criteria[:where] << [key, val]
      end
    end
    self
  end

  # Because of limited ability to manipulate what is returned
  # i.e., turn it into something other than the current class
  # I've commented the select method out for now.
  # def select(select_string)
  #   @cached_exec = nil
  #
  #   criteria[:select] = select_string
  # end

  def limit(num)
    @cached_exec = nil

    criteria[:limit] = num
    self
  end

  def order(order_string)
    @cached_exec = nil

    criteria[:order] = order_string
    self
  end

  def each(&prc)
    exec_query.each(&prc)
  end

  def count
    exec_query.count
  end

  alias_method :length, :count

  def [](index)
    exec_query[index]
  end

  def ==(object)
    exec_query == object
  end

  def first
    # not sure first and last work quite right
    unless @cached_exec
      limit(1)
      order("id ASC")
    end
    exec_query[0]
  end

  def last
    unless @cached_exec
      limit(1)
      order("id DESC")
    else
      exec_query[-1]
    end
  end

  def reload
    exec_query(true)
  end

  private
  # this method caches query results by default.
  def exec_query(reload = false)
    unless @cached_exec.nil? || reload
      @cached_exec
    else
      @cached_exec = @klass.send(:where_exec, criteria)
    end
  end

end

class SQLObject
  extend Searchable
end
