# Lazy loading and caching of query parts based on
# http://jeffkreeftmeijer.com/2011/method-chaining-and-lazy-evaluation-in-ruby/

class ModelRelation
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
    # TODO: not sure first and last work quite right
    unless @cached_exec
      limit(1)
      order("id ASC")
    end
    exec_query[0]
  end

  def last
    if !@cached_exec
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
    if !(@cached_exec.nil? || reload)
      @cached_exec
    else
      @cached_exec = @klass.send(:where_exec, criteria)
    end
  end

end
