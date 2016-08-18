module V1
  class IntegrationsController < VersionController

    before_action :authenticate

    def insight_grants
      @grants = Grant.approved
    end

    def amounts
      array_of_groups = []
      @amounts = []

      Organisation.funder.approved.each do |funder|
        array_of_groups << funder.recent_grants_as_funder.group_by { |o| o.fund_slug }
      end

      array_of_groups.each do |funder|
        funder.each do |fund|
          @amounts << {
            fund: fund[0],
            amounts: fund[1].map { |o| o.amount_awarded.to_f }
          }
        end
      end
    end

    protected

      def authenticate_token
        authenticate_with_http_token do |token, options|
          User.where(api_token: token, role: 'admin').first
        end
      end

  end
end
