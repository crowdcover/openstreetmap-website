require File.dirname(__FILE__) + '/../test_helper'

class GroupMembershipsControllerTest < ActionController::TestCase
  fixtures :users, :user_roles, :groups
  
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
  
  
  def test_invite_user
    #Leader only
    
    #adds a user
    
    #users gets email and message

  end
  
  def test_conform_invite
    
  end
  
  
end