require 'test_helper'

class StoriesControllerTest < ActionController::TestCase
  fixtures :users, :stories

  setup do
    @story = stories(:simple_story)
    @user = users(:normal_user)
  end

  
  def test_create_success
    assert_difference('Story.count', 1) do
      post :create,  {:story =>  {:title => "foobar", :description => "openstreetmap"}},  {:user => @user }
    end
    
    new_story = assigns(:story)
    assert_redirected_to story_path(new_story)
  end

  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stories)
  end

  
  test "should get new" do
    get :new,{},{:user => @user }
    assert_response :success
  end


  test "should show story" do
    get :show, :id => @story
    assert_response :success
  end

  
  test "should get edit" do
    get :edit, {:id => @story}, {:user => @user }
    assert_response :success
  end

  
  test "should update story" do
    patch :update,   { :id => @story, :story => {:title => @story.title, :description => "a new description" }}, {:user => @user }
    assert_redirected_to story_path(assigns(:story))
    new_story = @story.reload
    assert new_story.description == "a new description"
  end

  test "should destroy story" do
    assert_difference('Story.count', -1) do
      delete :destroy, {:id => @story}, {:user => @user }
    end
  
    assert_redirected_to stories_path
  end
end
