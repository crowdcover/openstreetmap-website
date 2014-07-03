class AddDraftToStories < ActiveRecord::Migration
  def change
    add_column :stories, :draft, :boolean
  end
end
