class AddFundSlugToGrant < ActiveRecord::Migration
  def up
    add_column :grants, :fund_slug, :string, required: true, index: true, uniqe: true

    Grant.all.find_each do |g|
      g.update_attribute(:fund_slug, g.award_year.to_s + '-' +
                                     g.funder.slug + '-' +
                                     g.funding_programme.parameterize)
    end
  end

  def down
    remove_column :grants, :fund_slug
  end
end
