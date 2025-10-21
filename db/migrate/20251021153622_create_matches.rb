class CreateMatches < ActiveRecord::Migration[8.0]
  def change
    create_table :matches do |t|
      t.references :lost_item, null: false, foreign_key: true
      t.references :found_item, null: false, foreign_key: true
      t.float :similarity_score
      t.string :status
      t.text :verification_answers

      t.timestamps
    end
  end
end
