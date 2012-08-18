class Table < ActiveRecord::Base

  # set_table_name @table_to_set
  # set_table_name {}
  # set_table_name "options"

  def find_tables
  end
  
  def find_table
  end
  
  def configure
    def get_db_config
      # Build the database config file string for this app
      apps_dir_path = session[:apps_dir_path]
      db_config_file = apps_dir_path + "/" +
                       params['application'] + "/config/database.yml"

      # Get the connection information
      db_config = YAML.load_file(db_config_file)

      # We'll only be looking at development databases
      db_config["development"]
    end
  end
end