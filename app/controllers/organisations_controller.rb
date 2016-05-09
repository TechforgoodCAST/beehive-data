class OrganisationsController < ApplicationController

  def index
    render json: Organisation.all
  end

end
