class CreateStories < ActiveRecord::Migration
  def change
    create_table :stories do |t|
      t.string :title
      t.text :description
      t.float :latitude
      t.float :longitude
      t.text :body

      t.references :user
      t.references :group
      
      t.timestamps
    end
    
    add_reference :users, :story, index: true
    add_reference :groups, :story, index: true
  end
end
