class AddUserToStoryAttachment < ActiveRecord::Migration
  def change
    add_column :story_attachments, :user_id, :integer
  end
end
