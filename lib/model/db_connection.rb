require 'sqlite3'

PRINT_QUERIES = ENV['PRINT_QUERIES'] == 'true'
# https://tomafro.net/2010/01/tip-relative-paths-with-file-expand-path
DB_FOLDER = File.join(File.dirname(__FILE__), '../../db/')

class DBConnection

  def self.db_file_exists?
    @@db_file_name && File.file?(DB_FOLDER + @@db_file_name)
  end

  def self.set_db_file(db_file_name)
    @@db_file_name = db_file_name
  end

  def self.open
    @db = SQLite3::Database.new(DB_FOLDER + @@db_file_name)
    @db.results_as_hash = true
    @db.type_translation = true

    @db
  end

  def self.reset(db_sql_file)

    if @@db_file_name
      commands = [
        "rm '#{DB_FOLDER}#{@@db_file_name}'",
        "cat '#{DB_FOLDER}#{db_sql_file}' |" +
        " sqlite3 '#{DB_FOLDER}#{@@db_file_name}'"
      ]

      commands.each { |command| `#{command}` }
      DBConnection.open
    else
      raise "Cannot reset DB file, DB file not set"
    end
  end

  def self.instance
    open if @db.nil?

    @db
  end

  def self.execute(*args)
    print_query(*args)
    instance.execute(*args)
  end

  def self.execute2(*args)
    print_query(*args)
    instance.execute2(*args)
  end

  def self.last_insert_row_id
    instance.last_insert_row_id
  end

  def self.print_query(query, *interpolation_args)
    return unless PRINT_QUERIES

    puts '--------------------'
    puts query
    unless interpolation_args.empty?
      puts "interpolate: #{interpolation_args.inspect}"
    end
    puts '--------------------'
  end
end
