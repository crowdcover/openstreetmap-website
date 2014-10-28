require File.dirname(__FILE__) + '/../test_helper'

class GroupCommentsControllerTest < ActionController::TestCase
  fixtures :users, :user_roles, :groups, :group_comments, :group_memberships
  
  def test_index
    #logged out user
    get :index, :group_id => groups(:british_cyclists_group).id
    assert_response :success
    assert_not_nil assigns(@group_comments)
    
    #logged in user
    get :index, {:group_id => groups(:british_cyclists_group).id}, {:user => users(:public_user).id}
    assert_response :success
    assert_not_nil assigns(@group_comments)
  end
  
  #moderator only view of all comments
  def test_list
    get :list, {:group_id => groups(:british_cyclists_group).id}, {:user => users(:public_user).id}
    assert_response :redirect
    
    get :list, {:group_id => groups(:british_cyclists_group).id}, {:user => users(:moderator_user).id}
    assert_response :success
    assert_not_nil assigns(@group_comments)
  end
  
  def test_show
    get :show, {:id => group_comments(:root_one).id, :group_id => groups(:british_cyclists_group).id }, {:user => users(:public_user).id}
    assert_response :success
    assert_not_nil assigns(@group_comment)
  end
  
  def test_create
    #user not in group
    assert_difference "GroupComment.count", 0 do
      post :create, {:group_id => groups(:british_cyclists_group).id, 'group_comment'=>{'title' => "new title", 'body' => "new body"}}, {:user => users(:normal_user).id}
    end
    
    assert_equal "Action not permitted. User is not in the group", flash[:error]
    assert_response :redirect

    #user  in group
    assert_difference "GroupComment.count", 1 do
      post :create, {:group_id => groups(:british_cyclists_group).id, 'group_comment'=>{'title' => "new title", 'body' => "new body"}}, {:user => users(:public_user).id}
    end
    assert_response :redirect

    assert_redirected_to group_comment_path(:id => GroupComment.last.id)
    comment = GroupComment.last
    assert comment.title, "new title"
  end
  
  def test_update
    comment = group_comments(:root_one)
    
    put :update, {:group_id => groups(:british_cyclists_group).id, :id => comment.id,  'group_comment'=>{'title' => "newer title", 'body' => "new body"}}, {:user => users(:normal_user).id}
 
    assert_equal "Action not permitted. User is not the author", flash[:error]
    
    
    #user  in group and author
    put :update, {:group_id => groups(:british_cyclists_group).id, :id => comment.id,  'group_comment'=>{'title' => "better title", 'body' => "new body"}}, {:user => users(:public_user).id}

    assert_response :redirect

    assert_redirected_to group_comment_path(:id => comment.id)
    comment = GroupComment.find(comment.id)
    assert comment.title, "better title2"
  end
  
  def test_delete
    @request.env['HTTP_REFERER'] = 'http://test.com/groups/1/comments'
   
    delete :destroy, {:group_id => groups(:british_cyclists_group).id, :id =>  group_comments(:root_one).id},  {:user => users(:normal_user).id}
    assert_response :redirect
    assert_equal "Action not permitted. User is not the author or moderator or a group lead", flash[:error]
    comment = GroupComment.last
    assert comment.visible
   
    delete :destroy, {:group_id => groups(:british_cyclists_group).id, :id =>  group_comments(:root_one).id},  {:user => users(:public_user).id}
    assert_response :redirect
    comment = GroupComment.last
    assert_equal false, comment.visible
    assert_equal "comment deleted", comment.body
  end
  
  
end