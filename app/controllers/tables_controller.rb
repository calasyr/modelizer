class TablesController < ApplicationController
  def index
    @application = params['application']
    
    begin
      @tables = tables(@application)
    rescue
      flash[:notice] = "The database for #{@application} could not be accessed."
      redirect_to controller: 'databases', action: 'index'
    end
  end
end
