class AddProfileFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :bio, :text
    add_column :users, :phone, :string
    add_column :users, :profile_photo, :string
    add_column :users, :contact_preference, :string
    add_column :users, :profile_visibility, :string
    add_column :users, :last_active_at, :datetime
  end
end
