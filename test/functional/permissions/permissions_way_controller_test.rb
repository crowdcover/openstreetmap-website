require File.dirname(__FILE__) + '/../../test_helper'

#
# Majority of permissions logic is in the permissions_node_controller_test
#

class PermissionsNodeControllerTest < ActionController::TestCase
  tests WayController
  
  api_fixtures
  fixtures :groups, :group_memberships, :users, :presets, :fields, :nodes

  def test_create_normal
    basic_authorization(users(:public_user).email, "test")
    
    nid1 = current_nodes(:used_node_1).id
    nid2 = current_nodes(:used_node_2).id

    # use the first user's open changeset
    changeset_id = changesets(:public_user_first_change).id
    
    # create a way with pre-existing nodes
    content "<osm><way changeset='#{changeset_id}'>" +
      "<nd ref='#{nid1}'/><nd ref='#{nid2}'/>" + 
      "<tag k='test' v='yes' /></way></osm>"
    put :create
    # hope for success
    assert_response :success
    # read id of created way and search for it
    wayid = @response.body
    checkway = Way.find(wayid)
    assert_not_nil checkway
  end

    
  def test_create_global_allowed
    basic_authorization users(:public_user).email, "test"
    
    nid1 = current_nodes(:used_node_1).id
    nid2 = current_nodes(:used_node_2).id
    changeset_id = changesets(:public_user_first_change).id
    
    # create a way with pre-existing nodes
    content "<osm><way changeset='#{changeset_id}'>" +
      "<nd ref='#{nid1}'/><nd ref='#{nid2}'/>" + 
      "<tag k='concession' v='mining' /></way></osm>"
    put :create
    # hope for success
    assert_response :success
    # read id of created way and search for it
    wayid = @response.body
    checkway = Way.find(wayid)
    assert_not_nil checkway
    
    assert_response :success
  end
  
  def test_create_global_forbidden
    basic_authorization(users(:moderator_user).email, "test")

    nid1 = current_nodes(:used_node_1).id
    nid2 = current_nodes(:used_node_2).id
    changeset_id = changesets(:moderator_user_first_change).id
    
    # create a way with pre-existing nodes
    content "<osm><way changeset='#{changeset_id}'>" +
      "<nd ref='#{nid1}'/><nd ref='#{nid2}'/>" + 
      "<tag k='concession' v='mining' /></way></osm>"
    put :create

    assert_response :forbidden
    
    assert @response.body.include?('Permission denied')
    assert @response.body.include?('concession:mining')
  end
  
  
  #even members cannot change the main tag
  def test_update_global_forbidden
    basic_authorization users(:public_user).email, "test"
     
    new_way = current_ways(:permissions_way).to_xml
    new_way.find("//osm/way/tag[@k='concession']").first['v'] = "foo"
    
    content new_way
    put :update, :id => current_ways(:permissions_way).id

    assert_response :forbidden
    assert @response.body.include?('Permission denied')
    assert @response.body.include?('concession:mining')
    
    #now change the key
    
    new_way = current_ways(:permissions_way).to_xml
    new_way.find("//osm/way/tag[@k='concession']").first['k'] = "bar"
    
    content new_way
    put :update, :id => current_ways(:permissions_way).id

    assert_response :forbidden
    assert @response.body.include?('Permission denied')
    assert @response.body.include?('concession:mining')
    
  end
  

  
  
  
end