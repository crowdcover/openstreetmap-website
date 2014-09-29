class AddInviteFieldsToGroupsMemberships < ActiveRecord::Migration
  def change
    add_column :group_memberships, :invite_token, :string
    add_column :group_memberships, :invite_accepted_at, :datetime
    add_column :group_memberships, :status, :string
  end
end
