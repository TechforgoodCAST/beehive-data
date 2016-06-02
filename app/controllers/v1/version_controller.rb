module V1
  class VersionController < ApplicationController
    abstract!

    before_action :authenticate

    protected

      def authenticate
        authenticate_token || render_unauthorised
      end

      def authenticate_token
        authenticate_with_http_token do |token, options|
          User.find_by(api_token: token)
        end
      end

      def render_unauthorised
        respond_to do |format|
          format.json { render json: 'Bad credentials', status: 401 }
        end
      end

  end
end
