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

    

end
