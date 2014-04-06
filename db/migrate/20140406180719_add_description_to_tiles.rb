class AddDescriptionToTiles < ActiveRecord::Migration
  def change
    add_column :tiles, :description, :text
  end
end
