class CreateGroupComments < ActiveRecord::Migration
  
  def change
    create_table :group_comments do |t|
      t.string :title, :limit => 100
      t.text :body
      t.boolean :visible, default: true, null: false
      t.references :group
      t.references :user
      t.references :parent
      t.timestamps
    end

    add_index :group_comments, :group_id
    add_index :group_comments, :parent_id
    add_index :group_comments, :user_id
  end
  
end
