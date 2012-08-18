class AssociationsController < ApplicationController
  def index
    about
    render :action => 'about'
  end

  def unauthorized
  end

  def conventions
  end

  def about
  end

  def info
    @partial = params['partial']
    @effect = params['effect']
  end  
end