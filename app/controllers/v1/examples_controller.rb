module V1
  class ExamplesController < ApplicationController

    respond_to :json

    def funders_by_year
      @funders = Organisation.funder.approved.limit(3) # TODO: limit for demo
      respond_with(@funders)
    end

    def grants_by_year
      @grants = Grant.approved.where(year: params[:year]) # TODO: limit for demo
      respond_with(@grants)
    end

  end
end
