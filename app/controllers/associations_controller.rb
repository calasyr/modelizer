class AssociationsController < ApplicationController
  layout false

  def index
    @table = params['table']
    @application = params['application']

    @associatable_columns = get_associations(@table, @application)
  end
end