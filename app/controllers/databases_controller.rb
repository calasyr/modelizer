class DatabasesController < ApplicationController
  def index
    # Find all apps with readable db config
    @readable_apps = get_applications.select do |application|
      File.readable_real?(apps_dir_path + "/" + application + "/config/database.yml")
    end
  end

  private
  
  def get_applications
    excludes = ['.', '..', 'modelizer']
    
    applications = Dir.new(apps_dir_path)

    # Find all apps with readable config/database.yml
    applications.select {|application| !excludes.include?(application)}
  end
end
