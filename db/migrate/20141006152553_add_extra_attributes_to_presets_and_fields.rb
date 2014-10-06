class AddExtraAttributesToPresetsAndFields < ActiveRecord::Migration
  def change
    add_column :presets, :geometry, :text
    add_column :presets, :name,  :string
    add_column :presets, :tags,  :text
    
    add_column :fields, :element,  :string
    add_column :fields, :tag_key,  :string
    add_column :fields, :label,  :string
    add_column :fields, :protect, :boolean
    
    add_reference :fields, :preset, index: true
    
  end
end
