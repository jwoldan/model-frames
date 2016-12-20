require_relative '../lib/model/db_connection'

DBConnection.set_db_file('gerbils.db')
DBConnection.reset('gerbils.sql') unless DBConnection.db_file_exists?
