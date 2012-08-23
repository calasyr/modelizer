class ApplicationController < ActionController::Base
  protect_from_forgery
    
  @@tables_to_ignore = ["schema_info", "schema_migrations", "sessions"]
  
  # Find the column names in each table that map to primary keys of other tables.
  def get_associations(this_table, application)    
    apps_tables = tables(application)
    apps_tables.delete(this_table)

    associations = []

    associatable_columns = associatable_columns(this_table, application)
    logger.info { "associatable_columns are #{associatable_columns}" }
    associatable_columns.each do |column|
      apps_tables.each do |other_table|
        if column == "#{other_table.singularize}_id"
          associations << {name: column, table: other_table}
        end
      end
    end

    associations
  end

  def associatable_columns table, application
    table_model = get_model(application)
    table_model.table_name = table
    
    columns = table_model.columns

    content_columns = table_model.content_columns.collect { |column| column.name }

    # Only columns that are ids can have associations
    columns.select! do |column|
      column.type.to_s == 'integer' && column.name != 'id' && !content_columns.include?(column.name)
    end

    columns.collect { |column| column.name }
  end

  def get_model(application)
    new_model = Class.new(ActiveRecord::Base)
    
    # Make sure the Table model is using the right db
    new_model.establish_connection(get_db_config(application))

    new_model
  end

  def tables application
    @application_tables ? @application_tables : get_tables(application)
  end
  
  def get_tables application
    # Connect to application database
    new_model = get_model(application)

    tables = new_model.connection.tables - @@tables_to_ignore
    
    @application_tables = tables
  end
    
  def get_db_config application
    if application
      # Build the database config file string for this app
      db_config_file = apps_dir_path + "/" + application + "/config/database.yml"

      # Get the connection information
      db_config = YAML.load_file(db_config_file)

      # We'll only be looking at development databases
      development = db_config['development']

      # Make sure the latest db adapter is used
      development['adapter'] = 'mysql2'

      development
    end
  end

  def apps_dir_path
    @apps_dir_path ? @apps_dir_path : (@apps_dir_path = File.dirname(FileUtils.pwd))
  end
end
