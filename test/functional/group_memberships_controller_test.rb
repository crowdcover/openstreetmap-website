require File.dirname(__FILE__) + '/../test_helper'

class GroupMembershipsControllerTest < ActionController::TestCase
  fixtures :users, :user_roles, :groups, :messages
  
  def test_index
    #logged out user
    get :index, :group_id => groups(:british_cyclists_group)
    assert_response :redirect
    assert_redirected_to :controller => :user, :action => "login", :referer => "/groups/1/users"
    
    #user not in that group
    get :index, {:group_id => groups(:british_cyclists_group)}, {:user => users(:second_public_user).id}
    assert_response :redirect
    assert_redirected_to groups(:british_cyclists_group), :referer => "/groups/1/users"
    
    #view for group lead    
    get :index, {:group_id => groups(:british_cyclists_group).id}, {:user => users(:normal_user).id}
    assert_response  :success
  
    #view allowed for admin
    get :index, {:group_id => groups(:british_cyclists_group).id}, {:user => users(:administrator_user).id}
    assert_response  :success
  
  end

  def test_update_role
   #logged out
    put :update_role,  {:user_id => users(:public_user).id, :group_id => groups(:british_cyclists_group).id}
    assert_response :forbidden
    
    #logged in by not permitted 
    put :update_role, {:user_id => users(:public_user).id, :group_id => groups(:british_cyclists_group).id}, {:user => users(:second_public_user).id }
    assert_response :redirect
    assert_redirected_to groups(:british_cyclists_group)
    
    assert_equal false,  groups(:british_cyclists_group).leadership_includes?(users(:public_user))
    
    #logged in and by a leader
    put :update_role, {:group_memberships_role => "Leader", :user_id => users(:public_user).id, :group_id => groups(:british_cyclists_group).id}, {:user => users(:normal_user).id }
    assert_response :redirect
    assert_redirected_to :action => :index, :group_id => groups(:british_cyclists_group).id
    
    uk_group = Group.find(1)
    assert uk_group.leadership_includes?(users(:public_user))

    #by an admin
    put :update_role, {:group_memberships_role => "", :user_id => users(:public_user).id, :group_id => groups(:british_cyclists_group).id}, {:user => users(:administrator_user).id }
    assert_response :redirect
    assert_redirected_to :action => :index, :group_id => groups(:british_cyclists_group).id
    
    uk_group = Group.find(1)
    assert_equal false,  groups(:british_cyclists_group).leadership_includes?(users(:public_user))

  end
  
 #group_user_invite GET            /groups/:group_id/users/:user_id/invite(.:format) 
  def test_invite_user
    #logged out
    get :invite,  {:user_id => users(:public_user).id, :group_id => groups(:british_cyclists_group).id}
    assert_response :redirect
    assert_redirected_to :controller => :user, :action => "login", :referer => "/groups/1/users/2/invite"
    
    #logged in but not leader
    get :invite, {:user_id => users(:public_user).id, :group_id => groups(:british_cyclists_group).id}, {:user => users(:second_public_user).id }
    assert_response :redirect
    assert_redirected_to groups(:british_cyclists_group)
    
    #as a leader
    get :invite, {:user_id => users(:second_public_user).id, :group_id => groups(:british_cyclists_group).id}, {:user => users(:normal_user).id }
    assert_response :redirect
    assert_redirected_to :action => :index, :group_id => groups(:british_cyclists_group).id
    
    assert_equal "Invite sent", flash[:notice]
    
    e = ActionMailer::Base.deliveries.first
    assert_equal [ users(:second_public_user).email ], e.to
    assert_equal "[Moabi] Invitation to join group British Cyclists", e.subject
    ActionMailer::Base.deliveries.clear
    m = Message.last
    assert_equal users(:normal_user).id, m.from_user_id
    assert_equal users(:second_public_user).id, m.to_user_id
    assert_in_delta Time.now, m.sent_on, 2

    assert_equal "html", m.body_format
    
    membership = users(:second_public_user).group_memberships.where(:group_id =>groups(:british_cyclists_group).id).first
    assert_equal "invited", membership.status

  end
  
  def test_confirm_invite
    get :invite, {:user_id => users(:second_public_user).id, :group_id => groups(:british_cyclists_group).id}, {:user => users(:normal_user).id }
    membership = users(:second_public_user).group_memberships.where(:group_id =>groups(:british_cyclists_group).id).first
    assert_equal "invited", membership.status
    token = membership.invite_token
    assert_not_nil token
    
    get :confirm_invite,  {:user_id => users(:second_public_user).id, :group_id => groups(:british_cyclists_group).id, :token => token},  {:user => users(:second_public_user).id }
    assert_response :redirect
    assert_redirected_to groups(:british_cyclists_group)
    
    membership = users(:second_public_user).group_memberships.where(:group_id =>groups(:british_cyclists_group).id).first
    assert_equal "active", membership.status
    assert  token != membership.invite_token
  end
  
  def test_remove
    skip "not written yet"
  end
  
end