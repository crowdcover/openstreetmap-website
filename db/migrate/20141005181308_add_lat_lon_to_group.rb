class AddLatLonToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :lon, :float
    add_column :groups, :lat, :float
  end
end
