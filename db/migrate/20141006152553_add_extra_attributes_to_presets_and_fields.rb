class AddExtraAttributesToPresetsAndFields < ActiveRecord::Migration
  def change
    add_column :presets, :geometry, :text
    add_column :presets, :name,  :string
    add_column :presets, :tags,  :text
    
    add_column :fields, :type,  :string
    add_column :fields, :key,  :string
    add_column :fields, :label,  :string
    
    add_reference :fields, :preset, index: true
    
  end
end
