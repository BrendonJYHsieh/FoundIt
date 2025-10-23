class MakeLostItemOptionalInMatches < ActiveRecord::Migration[8.0]
  def change
    change_column_null :matches, :lost_item_id, true
  end
end
