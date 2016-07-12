module V1
  class IntegrationsController < VersionController

    before_action :authenticate

    def insight_grants
      @grants = Grant.approved
    end

    protected

      def authenticate_token
        authenticate_with_http_token do |token, options|
          User.where(api_token: token, role: 'admin').first
        end
      end

  end
end
