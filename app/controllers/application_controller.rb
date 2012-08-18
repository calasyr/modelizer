class ApplicationController < ActionController::Base
  protect_from_forgery

  # Not in use, but may use it later to detect association methods already in use
  def find_associations(application,tables)

    association_methods = ["has_many", "has_one", "belongs_to", "has_and_belongs_to_many"]
    
    models_dir_path = apps_dir_path + "/" + application + "/app/models"

    tables.each do |table|
      model_file_path = models_dir_path + "/" + table.singularize + ".rb"

      if(File.readable_real?(model_file_path))
        File.open(model_file_path, "r") do |model_file|
          method_call_continues = false
          
          model_file.each_line do |line|
            trimmed = line.trim
            if(method_call_continues)
              logger.info("'#{trimmed}'")
              method_call_continues = trimmed.ends_with?(",")
            else 
              association_methods.each do |method|
                if(line.include?(method))
                  logger.info("'#{trimmed}'")
                  method_call_continues = trimmed.ends_with?(",")
                end
              end
            end
          end
        end
      end
    end
  end
    
  # Not in use, but may be used later to update the model file with new method calls
  def edit_model
    # Create an instance of the class for the specified model name and then discover its columns
    @class_name = params[:model]

    # Make sure the case is right
    
    if @class_name != nil 
      model_instance = eval("#{@class_name}.new")
    end

    if @model_instance != nil 
      @column_names = model_instance.attribute_names
    end

    # Get the associations from the file or the object
    
  end

  def get_associations(this_table, all_tables, counter)
    # Find the column names in each table that map to primary keys of other tables

    # Identify the columns in the specified table
    columns = get_columns(this_table)

    # content_columns = eval("#{model_name}.content_columns")
    Schema.table_name = this_table
    
    Schema.establish_connection(get_db_config)
    content_columns = Schema.content_columns

    columns.each do |column|
      # If the column IS NOT a content column and IS an integer

      # Ignore tbis column if its type is not integer, as it can't be an id
      if(column.type.to_s == "integer")
        not_content = true
        # Ignore this column if it is one of the content columns
        for content_column in content_columns
          if(content_column.name == column.name)
            not_content = false
          end
        end
        if(not_content)
          # See if a table name maps to the column name
          @tables.each do |table_again|
            if((table_again != "schema_info") && (table_again != @table))
              matching_column = table_again.singularize + "_id"
              if(matching_column == column.name)
                @associatable_column_names[counter] = [column.name,table_again]
                counter = counter + 1
              end
            end
          end
        end
      end
    end
    logger.info("#{@associatable_column_names.inspect}")
  end

  def show_table
    @application = params['application']
    @table = params['table']

    # Identify the tables in the database for this application
    @tables = Schema.connection.tables

    # Identify the columns in the specified table
    @columns = get_columns(@table)

    @associatable_column_names = Array.new
    counter = 0

    # Find the column names in each table that map to primary keys of other tables

    content_columns = eval("#{model_name}.content_columns")

    @columns.each do |column|
      # If the column IS NOT a content column and IS an integer

      # Its an array of content column elements, each of which is hash of
      # keys/values.  We need to find out if there is hash element whose key 
      # is "name" and whose value is the column name

      # Hey, if its not an integer, it can't be an id
      if(column.type.to_s == "integer")
        not_content = true
        for content_column in content_columns
          if(content_column.name == column.name)
            not_content = false
          end
        end
        if(not_content)
          # See if a table name maps to the column name
          @tables.each do |table_again|
            if((table_again != "schema_info") && (table_again != @table))
              matching_column = table_again.singularize + "_id"
              if(matching_column == column.name)
                @associatable_column_names[counter] = [column.name,table_again]
                counter = counter + 1
              end
            end
          end
        end
      end
    end
    logger.info("#{@associatable_column_names.inspect}")
  end

  def get_columns(table)
    # Identify the tables in the database for this application
    @tables = Schema.connection.tables
    logger.info { "@tables are #{@tables}" }

    # Make sure the Table model is using the right db
    Table.establish_connection(get_db_config)
    Table.table_name = table

    logger.info { "Table.column_names = #{Table.column_names}" }
    # Identify the columns in the specified table
    Table.columns
  end

  def get_db_config
    # Build the database config file string for this app
    db_config_file = apps_dir_path + "/" +
                     params['application'] + "/config/database.yml"

    # Get the connection information
    db_config = YAML.load_file(db_config_file)

    # We'll only be looking at development databases
    development = db_config['development']

    # Make sure the latest db adapter is used
    development['adapter'] = 'mysql2'

    development
  end

  def get_model_file_path(model_file_name)
    FileUtils.getwd() + "/app/models/" + model_file_name + ".rb"
  end

  def get_app_model
    @model_file_name = params['application']
    
    Schema.establish_connection(get_db_config)
  end
  
  def apps_dir_path
    @apps_dir_path ? @apps_dir_path : (@apps_dir_path = File.dirname(FileUtils.pwd))
  end
end
