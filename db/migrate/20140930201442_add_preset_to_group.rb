class AddPresetToGroup < ActiveRecord::Migration
  def change
    add_reference :presets, :group, index: true
  end
end
