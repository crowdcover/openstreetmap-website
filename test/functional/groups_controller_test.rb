require File.dirname(__FILE__) + '/../test_helper'

class GroupsControllerTest < ActionController::TestCase
  fixtures :users, :user_roles, :groups, :group_comments, :group_memberships
 
  
  def test_delete_failures
    #not logged in cannot
    delete :destroy, :id => groups(:british_cyclists_group).id
    assert_response :forbidden
    #non ground member cannot
    
    delete :destroy, {:id => groups(:british_cyclists_group).id}, {:user => users(:normal_user).id}
    assert_response :redirect
    assert_redirected_to groups(:british_cyclists_group)
    assert flash[:error].include?("group lead")
    assert flash[:error].include?("administrator")
    
    #normal group member cannot
    delete :destroy, {:id => groups(:british_cyclists_group).id}, {:user => users(:second_public_user).id}
    assert_response :redirect
    assert_redirected_to groups(:british_cyclists_group)
    assert flash[:error].include?("group lead")
    assert flash[:error].include?("administrator")
    
    #a moderator cannot either
    delete :destroy, {:id => groups(:british_cyclists_group).id}, {:user => users(:moderator_user).id}
    assert_response :redirect
    assert_redirected_to groups(:british_cyclists_group)
    assert flash[:error].include?("group lead")
    assert flash[:error].include?("administrator")
  end
  
  def test_delete_by_lead
    # a group lead can delete
    assert_nothing_raised(ActiveRecord::RecordNotFound) { 
      GroupMembership.find(group_memberships(:public_british).id)
    }
    assert_nothing_raised(ActiveRecord::RecordNotFound) { 
      GroupComment.find(group_comments(:root_one).id)
    }
    
    delete :destroy, {:id => groups(:british_cyclists_group).id}, {:user => users(:public_user).id}
    assert_response :redirect
    assert_redirected_to groups_path
    assert_equal "Group deleted", flash[:notice]
 
    assert_raise(ActiveRecord::RecordNotFound) { 
      #memberships also deleted
      GroupMembership.find(group_memberships(:public_british).id)
    }
    assert_raise(ActiveRecord::RecordNotFound) { 
      # any discussions also deleted
      GroupComment.find(group_comments(:root_one).id)
    }
    
  end
  
  def test_delete_by_moderator
    assert_nothing_raised(ActiveRecord::RecordNotFound) { 
      GroupMembership.find(group_memberships(:public_british).id)
    }
    assert_nothing_raised(ActiveRecord::RecordNotFound) { 
      GroupComment.find(group_comments(:root_one).id)
    }
    
    delete :destroy, {:id => groups(:british_cyclists_group).id}, {:user => users(:administrator_user).id}
    assert_response :redirect
    assert_redirected_to groups_path
    assert_equal "Group deleted", flash[:notice]
    
    assert_raise(ActiveRecord::RecordNotFound) { 
      #memberships also deleted
      GroupMembership.find(group_memberships(:public_british).id)
    }
    assert_raise(ActiveRecord::RecordNotFound) { 
      # any discussions also deleted
      GroupComment.find(group_comments(:root_one).id)
    }
  end
  
  
  def test_new
    skip "not written yet"
  end
  
  def test_create
    skip "not written yet"
  end
  
  def test_update
    skip "not written yet"
  end
  
  def test_show
    skip "not written yet"
  end
  
  def test_index
    skip "not written yet"
  end
  
  def test_schema
    skip "not written yet"
  end
  
  def test_presets
    skip "not written yet"
  end
  
end