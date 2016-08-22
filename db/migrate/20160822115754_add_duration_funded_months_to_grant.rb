class AddDurationFundedMonthsToGrant < ActiveRecord::Migration
  def up
    add_column :grants, :duration_funded_months, :integer
    Grant.where(
      'planned_start_date IS NOT NULL AND planned_end_date IS NOT NULL'
    ).each do |grant|
      grant.update_column(
        :duration_funded_months,
        (grant.planned_end_date.year * 12 + grant.planned_end_date.month) - (grant.planned_start_date.year * 12 + grant.planned_start_date.month)
      )
    end
  end

  def down
    remove_column :grants, :duration_funded_months
  end
end
