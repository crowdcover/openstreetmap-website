class CreateStoryAttachments < ActiveRecord::Migration
  def change
    create_table :story_attachments do |t|
      t.text :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.string :image_fingerprint, index: true

      t.timestamps
    end
  end
end
