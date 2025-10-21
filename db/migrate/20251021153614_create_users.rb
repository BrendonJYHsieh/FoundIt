class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :uni
      t.string :password_digest
      t.boolean :verified
      t.integer :reputation_score

      t.timestamps
    end
  end
end
