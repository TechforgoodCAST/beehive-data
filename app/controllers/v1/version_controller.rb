module V1
  class VersionController < ApplicationController
    abstract!

    before_action :authenticate

    protected

      def auth_admin
        request.headers["Authorization"] = "Token token=#{current_user.api_token}" if current_user
      end

      def authenticate
        auth_admin
        authenticate_token || render_unauthorised
      end

      def authenticate_token
        authenticate_with_http_token do |token, options|
          User.find_by(api_token: token)
        end
      end

      def render_unauthorised
        render json: { unauthorized: "Bad credentials" }, status: 401
      end

  end
end
