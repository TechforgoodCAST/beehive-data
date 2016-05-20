module V1
  class FundersController < VersionController

    def index
      @funders = Organisation.funder.approved
    end

  end
end
