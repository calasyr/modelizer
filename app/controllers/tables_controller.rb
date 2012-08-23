class TablesController < ApplicationController
  def show
    # Identify the tables in the database for this application
    # @tables = eval("#{get_app_model}.connection.tables")
    Schema.establish_connection(get_db_config)
    @tables = Schema.connection.tables
    @table = params['table']
    
    @associatable_column_names = Array.new
    counter = 0
    get_associations(@table, @tables, counter)
  end

  end
end
