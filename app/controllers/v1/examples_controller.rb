module V1
  class ExamplesController < ApplicationController

    def funders_by_year
      @funders = Organisation.funder.approved.limit(3) # TODO: limit for demo
    end

    def grants_by_year
      @grants = Grant.includes({recipient: [:country]}, :countries, :districts, :age_groups, :beneficiaries, :ages, :regions).approved.where(award_year: params[:year]).order("RANDOM()").limit(20)
    end

  end
end
