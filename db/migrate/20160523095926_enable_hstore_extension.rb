class EnableHstoreExtension < ActiveRecord::Migration
  def change
    add_column :organisations, :scrape, :json, default: {}, null: false, index: true
  end
end
