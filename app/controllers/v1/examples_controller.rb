module V1
  class ExamplesController < ApplicationController

    respond_to :json

    def funders
      @funders = Organisation.funder.approved # TODO: limit for demo
      respond_with(@funders)
    end

    def by_year
      @grants = Grant.approved.where(year: params[:year]) # TODO: limit for demo
      respond_with(@grants)
    end

  end
end
