class AddAuthorToStories < ActiveRecord::Migration
  def change
    add_column :stories, :author, :string
  end
end
