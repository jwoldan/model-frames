require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @primary_key = options[:primary_key] || :id
    @foreign_key = options[:foreign_key] ||
      "#{name.to_s.downcase}_id".to_sym
    @class_name = options[:class_name] || name.to_s.camelcase
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @primary_key = options[:primary_key] || :id
    @foreign_key = options[:foreign_key] ||
      "#{self_class_name.downcase}_id".to_sym
    @class_name = options[:class_name] ||
      name.to_s.singularize.camelcase
  end
end

module Associatable

  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)
    define_method(name) do
      foreign_key = self.send(self.class.assoc_options[name].foreign_key)
      self.class.assoc_options[name].model_class.where(id: foreign_key).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)
    define_method(name) do
      primary_key = self.send(options.primary_key)
      options.model_class.where(options.foreign_key => primary_key)
    end
  end

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

  def assoc_options
    @assoc_options ||= {}
  end
end
