class UpdateFundSlug < ActiveRecord::Migration
  def up
    Grant.where('fund_slug IS NOT NULL').find_each do |grant|
      grant.update_attribute(:fund_slug, grant.fund_slug.slice(5..-1))
      print '.'
    end
  end
end
