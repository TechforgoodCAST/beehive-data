module V1
  class IntegrationsController < VersionController

    before_action :authenticate

    def beneficiaries
      @grants = Grant.includes(:recipient)
                     .recent(Grant.pluck(:fund_slug).uniq)
    end

    def amounts
      @amounts = parse_values('amounts', 'amount_awarded')
    end

    def durations
      @durations = parse_values('durations', 'duration_funded_months', true)
    end

    def fund_summary
      @grants = Grant.recent(params[:fund_slug])
    end

    protected

      def authenticate_token
        authenticate_with_http_token do |token, options|
          User.where(api_token: token, role: 'admin').first
        end
      end

      def parse_values(key, field, durations=false)
        array_of_groups = []
        result = []

        Organisation.funder.approved.each do |funder|
          if durations
            array_of_groups << funder.recent_grants_as_funder.where('planned_start_date IS NOT NULL AND planned_end_date IS NOT NULL').group_by { |o| o.fund_slug }
          else
            array_of_groups << funder.recent_grants_as_funder.group_by { |o| o.fund_slug }
          end
        end

        array_of_groups.each do |funder|
          funder.each do |fund|
            result << {
              :fund => fund[0],
              :"#{key}".to_sym => fund[1].map { |o| o.send(field).to_f }
            }
          end
        end

        return result
      end

  end
end
