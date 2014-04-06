require 'test_helper'

class TilesControllerTest < ActionController::TestCase
  fixtures :tiles
  api_fixtures

  setup do
    @tile = tiles(:one)
  end

  def test_routes
    assert_routing(
      { :path => "/api/0.6/tiles", :method => :post },
      { :controller => "tiles", :action => "create" }
    )
    assert_routing(
      { :path => "/api/0.6/tiles/1", :method => :get },
      { :controller => "tiles", :action => "show", :id => "1" }
    )
    assert_recognizes(
      { :controller => "tiles", :action => "show", :id => "1", :format => "json" },
      { :path => "/api/0.6/tiles/1.json", :method => :get }
    )
    assert_routing(
      { :path => "/api/0.6/tiles/1.json", :method => :get },
      { :controller => "tiles", :action => "show", :id => "1", :format => "json" }
    )
  end
  
  def test_create_success
    basic_authorization(users(:moderator_user).email, "test")
    assert_difference('Tile.count') do
      post :create, {:url =>"foo", :attribution=>"bar",:name=>"foo", :code => "F", :keyid => "Key", :subdomains => "fooo",:base_layer => "doo", :description => "Description here.", :format => "json" }
    end

    assert_response :success
    #js = ActiveSupport::JSON.decode(@response.body)
    #assert_not_nil js
  end

  #test "should get index" do
  #  get :index
  #  assert_response :success
  #  assert_not_nil assigns(:presets)
  #end

  #test "should get new" do
  #  get :new
  #  assert_response :success
  #end


  #test "should show preset" do
  #  get :show, id: @preset
  #  assert_response :success
  #end

  #test "should get edit" do
  #  get :edit, id: @preset
  #  assert_response :success
  #end

  #test "should update preset" do
  #  patch :update, id: @preset, preset: { name: @preset.name, text: @preset.text }
  #  assert_redirected_to preset_path(assigns(:preset))
  #end

  #test "should destroy preset" do
  #  assert_difference('Preset.count', -1) do
  #    delete :destroy, id: @preset
  #  end
  #
  #  assert_redirected_to presets_path
  #end
end