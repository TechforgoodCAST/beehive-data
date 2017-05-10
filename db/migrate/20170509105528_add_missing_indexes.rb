class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :ages, :age_group_id
    add_index :ages, :grant_id
    add_index :locations, :country_id
    add_index :locations, :grant_id
    add_index :regions, :district_id
    add_index :regions, :grant_id
    add_index :grants, :fund_slug
    add_index :grants, :award_date
    add_index :grants, :state
  end
end
