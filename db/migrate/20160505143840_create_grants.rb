class CreateGrants < ActiveRecord::Migration
  def change
    create_table :grants do |t|
      t.string :grant_identifier, :funder_identifier, :recipient_identifier, required: true
      t.timestamps null: false
    end

    create_table :beneficiaries do |t|
      t.string :label, :sort, required: true
      t.timestamps null: false
    end

    create_table :beneficiaries_grants do |t|
      t.references :beneficiary
      t.references :grant
    end

    add_index :grants, :grant_identifier, unique: true
    add_index :grants, :recipient_identifier
    add_index :grants, :funder_identifier
  end
end
