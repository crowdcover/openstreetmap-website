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
  
  test "create success" do
    basic_authorization(users(:moderator_user).email, "test")
    assert_difference('Tile.count') do
      post :create, :tile => {:url =>"foo", :attribution=>"bar",:name=>"foo", :code => "F", :keyid => "Key", :subdomains => "fooo",:base_layer => "doo", :description => "Description here."},  :format => "json" 
    end

    assert_response :success
    js = ActiveSupport::JSON.decode(@response.body)
    assert_not_nil js
  end
  
    
  test "create without necesary name parameter fails" do
    basic_authorization(users(:moderator_user).email, "test")
    assert_no_difference('Tile.count') do
      post :create, :tile => { :code => "B", :keyid=>"bb", :subdomains => "fooo",:base_layer => "doo", :description => "Description here."}, :format => "json" 
    end
    assert_response :bad_request

    assert_equal "No name was given" ,  @response.header["Error"]
  end
  

  test "should get list all tiles json" do
    get :index, :format => "json"
    assert_response :success
    js = ActiveSupport::JSON.decode(@response.body)
    assert_not_nil js
    assert_equal js.size, Tile.count 
    assert_equal @tile.name, js["#{@tile.id}"]["name"]
  end


  test "should show tile " do
    get :show, id: @tile, format: "json"
    assert_response :success
    js = ActiveSupport::JSON.decode(@response.body)
    assert_not_nil js
    assert_equal @tile.name, js["#{@tile.id}"]["name"]
  end



  test "should update tile" do
    basic_authorization(users(:moderator_user).email, "test")
    patch :update, id: @tile, tile: {name: "new name"}, format: "json"
    js = ActiveSupport::JSON.decode(@response.body)
    assert_not_nil js
    assert_equal "new name", js["#{@tile.id}"]["name"]
    @tile.reload
    assert_equal "new name", @tile.name
  end

  test "should destroy tile" do
    basic_authorization(users(:moderator_user).email, "test")
    assert_difference('Tile.count', -1) do
      delete :destroy, id: @tile, format: "json"
    end
    
    assert_response :success
    
  end
end


