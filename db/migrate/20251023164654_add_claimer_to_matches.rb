class AddClaimerToMatches < ActiveRecord::Migration[8.0]
  def change
    add_column :matches, :claimer_id, :integer
  end
end
