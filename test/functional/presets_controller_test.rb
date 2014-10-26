require File.dirname(__FILE__) + '/../test_helper'

class PresetsControllerTest < ActionController::TestCase
  fixtures :users, :presets

  setup do
    @preset = presets(:one)
  end

  def test_routes
    assert_routing(
      { :path => "/api/0.6/presets", :method => :post },
      { :controller => "presets", :action => "create" }
    )
    assert_routing(
      { :path => "/api/0.6/presets/1", :method => :get },
      { :controller => "presets", :action => "show", :id => "1" }
    )
    assert_recognizes(
      { :controller => "presets", :action => "show", :id => "1", :format => "json" },
      { :path => "/api/0.6/presets/1.json", :method => :get }
    )
    assert_routing(
      { :path => "/api/0.6/presets/1.json", :method => :get },
      { :controller => "presets", :action => "show", :id => "1", :format => "json" }
    )
  end

  def test_create_success
    basic_authorization(users(:normal_user).email, "test")
    json = '{"geometry":["point","line","area"],"name":"new preset","tags":{"natural":"mountain"},"fields":["1","2"]}'
    assert_difference('Preset.count', 1) do     
      post :create, json, "CONTENT_TYPE" => 'application/json'
    end

    assert_response :success
    js = ActiveSupport::JSON.decode(@response.body)
    assert_not_nil js
    assert_not_nil js["id"]
  end
  
  def test_create_tags_unique_validation
    #Can't figure out how to correctly represent an ActiveRecord:Store in a yaml fixture, so just force the preset to save it in the correct format via:
    one_preset = Preset.find(presets(:one).id)
    one_preset.save
    
    basic_authorization(users(:normal_user).email, "test")

    json = '{"geometry":["point","line","area"],"name":"new preset","tags":{"natural":"forest"},"fields":["1","2"]}'
    assert_difference('Preset.count', 0) do     
      post :create, json, "CONTENT_TYPE" => 'application/json'
    end

    assert_response :bad_request
    assert_equal "Preset already taken with the same tags", @response.body
  end

  test "should get index" do
    get :index, :format => "json"
    assert_response :success
    assert_not_nil assigns(:presets)

    js = ActiveSupport::JSON.decode(@response.body)
    assert_equal 2, js.size
    assert_equal [presets(:one).name, presets(:two).name], js.map{|preset|  preset[1]["name"]}
    assert_equal ["moabi/#{presets(:one).id}", "moabi/#{presets(:two).id}"], js.map{|preset|  preset[0]}
  end

  test "should show preset" do
    get :show, id: presets(:two).id, :format => "json"
    assert_response :success
    assert_not_nil assigns(:preset)
 
    js = ActiveSupport::JSON.decode(@response.body)
    assert_equal presets(:two).name, js["moabi/#{presets(:two).id}"]["name"]
    assert_equal presets(:two).group_id.to_s, js["moabi/#{presets(:two).id}"]["group_id"]
  end
  
  test "should show preset when changed" do
    preset = Preset.find(presets(:two).id)
    preset.name = "changed name"
    preset.save
    
    get :show, id: presets(:two).id, :format => "json"
    assert_response :success
    assert_not_nil assigns(:preset)

    js = ActiveSupport::JSON.decode(@response.body)
    assert_equal "changed name", js["moabi/#{presets(:two).id}"]["name"]
    assert_equal presets(:two).group_id.to_s, js["moabi/#{presets(:two).id}"]["group_id"]
  end


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
