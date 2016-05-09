class FundersController < ApplicationController

  def index
    render json: Organisation.funders
  end

end
