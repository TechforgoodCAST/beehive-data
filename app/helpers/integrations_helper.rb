module IntegrationsHelper

  def period_start
    if @grants.count==0
      365.days.ago.to_date
    else
      grants = @grants.order(:award_date)
      first = grants.first.award_date
      last = grants.last.award_date
      last > first - 365 ? first : last - 365
    end
  end

  def period_end
    if @grants.count==0
      Time.now.to_date
    else
      @grants.order(:award_date).last.award_date
    end
  end

  def org_type_distribution
    sort_append(
      Organisation::ORG_TYPE,
      @grants.joins(:recipient).group('organisations.org_type').count
    )
  end

  def operating_for_distribution
    sort_append(
      Grant::OPERATING_FOR,
      @grants.group(:operating_for).count
    )
  end

  def income_distribution
    sort_append(
      Grant::INCOME,
      @grants.group(:income).count
    )
  end

  def employees_distribution
    sort_append(
      Grant::EMPLOYEES,
      @grants.group(:employees).count
    )
  end

  def volunteers_distribution
    sort_append(
      Grant::EMPLOYEES,
      @grants.group(:volunteers).count
    )
  end

  def geographic_scale_distribution
    sort_append(
      Grant::GEOGRAPHIC_SCALE,
      @grants.group(:geographic_scale).count,
      unknown: true
    )
  end

  def grant_examples
    result = []
    @grants.sample(5).each do |grant|
      result << {
        title: grant.title,
        recipient: grant.recipient.name,
        amount: grant.amount_awarded,
        currency: grant.currency,
        award_date: grant.award_date,
        id: grant.grant_identifier
      }
    end
    result
  end

  def gender_distribution(data: @grants.group(:gender).count)
    result = []
    data.sort_by { |k,v| v }.reverse.each_with_index do |(k,v), i|
      result << {
        position: i + 1,
        label: (k.nil? ? 'N/A' : k),
        count: v,
        percent: v.to_f / @grants.count # TODO: refactor
      }
    end
    Grant::GENDERS.reject { |i| result.map { |hsh| hsh[:label] }.include?(i) }
    .each do |i|
      result << {
        position: result.size + 1,
        label: i,
        count: 0,
        percent: 0.0
      }
    end
    result
  end

  def amount_awarded_distribution(data: @grants.pluck(:amount_awarded), range: 5000)
    buckets = [0, 50, 300, 750, 1500, 3500, 7500, 12500, 17500, 27500, 35000, 45000, 75000, 300000, 5250000]
    result = []
    # grouping amounts to reduce # of inputs
    # ordering amounts to determine bucket limits
    grouped = data.map { |amount| amount.to_i }.group_by do |amount|
      buckets.find_index { |range| range > amount } - 1
    end
    buckets.each_with_index do |v, i|
      result << {
        start: v,
        end: buckets.fetch(i+1, 9007199254740992) - 1,
        segment: i,
        percent: grouped.fetch(i, []).length / data.length,
        count: grouped.fetch(i, []).length,
      }
    end
    result
  end

  def award_month_distribution(data: @grants)
    result = []
    grouped = data.group_by_month(:award_date, format: '%-m')
    sum = grouped.calculate(:sum, :amount_awarded)
    grouped.count.each do |k,v|
      result << {
        month: k.to_i,
        count: v,
        percent: v.to_f / @grants.count, # TODO: refactor
        amount: sum[k].to_f.round(2)
      }
    end
    result
  end

  def duration_months_distribution(data: @grants.pluck(:duration_funded_months), range: 3)
    result = []
    data.group_by { |m| (m % 3 == 0 ? (m / 3) - 1 : m / 3) + 1 }.each do |k,v|
      result << {
        segment: k,
        quarter: ['Oct - Dec', 'Jan - Mar', 'Apr - Jun', 'Jul - Sep'][k % 4],
        range: "#{range * k + 1 - range} - #{range * k} months",
        count: v.count
      } if k > 0
    end
    result
  end

  def country_distribution(data: @grants.joins(:countries).group('countries.alpha2', 'countries.name').count)
    result = []
    data.each do |k,v|
      result << {
        name: k[1],
        alpha2: k[0],
        count: v,
        percent: v.to_f / @grants.count # TODO: refactor
      }
    end
    result.sort_by { |hash| hash[:count] }.reverse
  end

  def district_distribution(data: @grants.joins(:districts).group(:name).count)
    # TODO: refactor
    result = []
    data.each do |k,v|
      result << {
        name: k,
        count: v,
        percent: v.to_f / @grants.count # TODO: refactor
      }
    end
    result.sort_by { |hash| hash[:count] }.reverse
  end

  def age_group_distribution
    map_to(
      AgeGroup::AGE_GROUPS,
      @grants.joins(:age_groups).group(:label).count
    )
  end

  def beneficiary_distribution
    map_to(
      Beneficiary::BENEFICIARIES,
      @grants.joins(:beneficiaries).group(:label).count
    )
  end

  private

    def sort(data, const, result, unknown: false)
      data.sort_by { |k,v| v }.reverse.each_with_index do |arr, i|
        result << {
          position: i + 1,
          label: const[unknown ? arr[0] : arr[0] + 1][0],
          count: arr[1].to_f,
          percent: arr[1].to_f / data.values.sum
        }
      end
    end

    def append(const, result)
      const
        .map { |i| i[0] }
        .reject { |i| result.map { |hsh| hsh[:label] }.include?(i) }
        .each do |i|
          result << {
            position: result.size + 1,
            label: i,
            count: 0,
            percent: 0.0
          }
        end
    end

    def sort_append(const, data, unknown: false)
      result = []
      sort(data, const, result, unknown: unknown)
      append(const, result)
      result
    end

    def map_to(const, data)
      result = []
      const.each do |hash|
        count = data[hash[:label]]
        result << hash.merge(
          count: count || 0,
          percent: count.to_f / @grants.count || 0 # TODO: refactor
        )
      end
      result.sort_by { |hash| hash[:count] }.reverse.each_with_index do |hash, i|
        hash[:position] = i + 1
      end
    end

end
