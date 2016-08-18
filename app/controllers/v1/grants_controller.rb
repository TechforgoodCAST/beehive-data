module V1
  class GrantsController < VersionController

    before_action :load_funder, except: :by_year

    def by_year
      @grants = Grant.newest.approved.where(award_year: params[:year]) # TODO: refactor
    end

    def by_funder
      @grants = Grant.approved.where(award_year: params[:year], funder: @funder) # TODO: refactor
    end

    def by_programme
      @grants = Grant.approved.where(award_year: params[:year],
                                     funder: @funder,
                                     funding_programme: params[:programme]) # TODO: refactor
    end

    # TODO: use recent grants instead of annual for beehive-giving analysis
    # def recent_by_funder
    #   @grants = @funder.recent_grants_as_funder if params[:funder]
    # end

    private

      def load_funder
        @funder = Organisation.funder.find_by(slug: params[:funder])
      end

  end
end
