class CreateFoundItems < ActiveRecord::Migration[8.0]
  def change
    create_table :found_items do |t|
      t.references :user, null: false, foreign_key: true
      t.string :item_type
      t.text :description
      t.string :location
      t.datetime :found_date
      t.text :photos
      t.string :status

      t.timestamps
    end
  end
end
