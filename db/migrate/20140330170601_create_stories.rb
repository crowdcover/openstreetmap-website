class CreateStories < ActiveRecord::Migration
  def change
    create_table :stories do |t|
      t.string :title
      t.text :description
      t.float :latitude
      t.float :longitude
      t.integer :zoom
      t.text :layers
      t.text :body
      t.string :filename
      t.string :layout
      t.string :language
      t.string :image_url
      
      t.references :user
      t.references :group
      
      t.timestamps
    end
    
    add_reference :users, :story, index: true
    add_reference :groups, :story, index: true
  end
end
