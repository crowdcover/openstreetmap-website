class AddUserToField < ActiveRecord::Migration
  def change
    add_column :fields, :user_id, :integer

    reversible do |dir|
        dir.up do
            execute <<-SQL
                ALTER TABLE fields
                    ADD CONSTRAINT fk_fields_users
                    FOREIGN KEY (user_id)
                    REFERENCES users(id)
            SQL
        end
        dir.down do
            execute <<-SQL
                ALTER TABLE fields
                    DROP FOREIGN KEY fl_fields_users
            SQL
        end
    end
  end
end
