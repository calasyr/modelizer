class Schema < ActiveRecord::Base
  def find_schema
  end

  private
  
  def get_db_config
    # Build the database config file string for this app
    db_config_file = apps_dir_path + "/" +
                     params['application'] + "/config/database.yml"

    logger.info "db_config_file is #{db_config_file}"
    
    # Get the connection information
    db_config = YAML.load_file(db_config_file)

    # We'll only be looking at development databases
    db_config["development"]
  end
end