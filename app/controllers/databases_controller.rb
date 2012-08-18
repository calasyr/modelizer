class DatabasesController < ApplicationController
  def index
    excludes = ['.', '..', 'modelizer']
    
    @applications = Dir.new(apps_dir_path)

    @readable_apps = Array.new

    # Find all apps with readable config/database.yml
    @applications.each do |application|
      if !excludes.include?(application)
        apps_path = apps_dir_path + "/" + application
        db_config_file = apps_path + "/config/database.yml"

        if File.readable_real?(db_config_file)
          @readable_apps << application
        end
      end
    end
  end

  def show
    @application = params['application']

    Schema.establish_connection(get_db_config)
    
    # Identify the tables in the database for this application
    begin
      @tables = Schema.connection.tables - ["schema_info", "schema_migrations", "sessions"]

      if @tables.length > 0
        # Get the button sets
        @button_set = @tables.collect do |table|
          {table: table, application: @application}
        end
      end
    rescue
      flash[:notice] = "The database for #{@application} could not be accessed."
      redirect_to :action => 'index'
    end
  end  
end
