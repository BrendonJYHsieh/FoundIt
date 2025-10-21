class CreateLostItems < ActiveRecord::Migration[8.0]
  def change
    create_table :lost_items do |t|
      t.references :user, null: false, foreign_key: true
      t.string :item_type
      t.text :description
      t.string :location
      t.datetime :lost_date
      t.text :verification_questions
      t.text :photos
      t.string :status

      t.timestamps
    end
  end
end
