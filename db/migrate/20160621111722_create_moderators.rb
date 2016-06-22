class CreateModerators < ActiveRecord::Migration
  def change
    create_table :moderators do |t|
      t.references :approvable, polymorphic: true, index: true
      t.references :user, index: true
    end
    add_column :users, :role, :string, required: true, default: 'moderator'
    add_column :users, :first_name, :string, required: true
    add_column :users, :last_name, :string, required: true
    add_column :users, :initials, :string, required: true
  end
end
