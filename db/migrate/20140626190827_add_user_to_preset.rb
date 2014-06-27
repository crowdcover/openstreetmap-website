class AddUserToPreset < ActiveRecord::Migration
  def change
    add_column :presets, :user_id, :integer
    
    reversible do |dir|
        dir.up do
            # add foreign key
            execute <<-SQL
                ALTER TABLE presets
                    ADD CONSTRAINT fk_presets_users
                    FOREIGN KEY (user_id)
                    REFERENCES users(id)
            SQL
        end
        dir.down do
            # remove foreign key
            execute <<-SQL
                ALTER TABLE presets
                    DROP FOREIGN KEY fk_presets_users
            SQL
        end
    end
  end
end