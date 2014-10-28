require File.dirname(__FILE__) + '/../../test_helper'

class PermissionsNodeControllerTest < ActionController::TestCase
  tests NodeController
  
  api_fixtures
  fixtures :groups, :group_memberships, :users, :presets, :fields, :nodes
  
  def test_create_normal
    basic_authorization(users(:public_user).email, "test")
    
    # create a node with random lat/lon
    lat = rand(100)-50 + rand
    lon = rand(100)-50 + rand
    # normal user has a changeset open, so we'll use that.
    changeset = changesets(:public_user_first_change)
    # create a minimal xml file
    content("<osm><node lat='#{lat}' lon='#{lon}' changeset='#{changeset.id}'><tag k='foo' v='bar'/></node></osm>")
    put :create
    # hope for success
    assert_response :success

    # read id of created node and search for it
    nodeid = @response.body
    checknode = Node.find(nodeid)
    assert_not_nil checknode
    # compare values
    assert_in_delta lat * 10000000, checknode.latitude, 1
    assert_in_delta lon * 10000000, checknode.longitude, 1
    assert_equal changesets(:public_user_first_change).id, checknode.changeset_id
    assert_equal true, checknode.visible
  end
  
  def test_create_global_allowed
    basic_authorization(users(:public_user).email, "test")
    node_xml = "<osm><node id='23' lat='23.43' lon='23.32' changeset='#{changesets(:public_user_first_change).id}' version='32'><tag k='concession' v='mining' /><tag k='name' v='a value' /></node></osm>"
    
    content(node_xml)
    assert_difference('Node.count', 1) do
      put :create
    end
    assert_response :success
    
    nodeid = @response.body
    checknode = Node.find(nodeid)
    assert_not_nil checknode
    assert 23.24, checknode.latitude
    assert_equal changesets(:public_user_first_change).id, checknode.changeset_id
    assert_equal true, checknode.visible
  end
  
  def test_create_node_global_forbidden
    basic_authorization(users(:moderator_user).email, "test")
    node_xml = "<osm><node id='23' lat='23.43' lon='23.32' changeset='#{changesets(:moderator_user_first_change).id}' version='32'><tag k='concession' v='mining' /><tag k='name' v='a value' /></node></osm>"

    content(node_xml)
    assert_difference('Node.count', 0) do
      put :create
    end

    assert_response :forbidden
    
    assert @response.body.include?('Permission denied')
    assert @response.body.include?('concession:mining')
  end
  
  def test_create_node_local_allowed
    basic_authorization(users(:public_user).email, "test")
    node_xml = "<osm><node id='23' lat='23.43' lon='23.32' changeset='#{changesets(:public_user_first_change).id}' version='32'><tag k='concession' v='mining' /><tag k='website' v='osm.org' /></node></osm>"

    content(node_xml)
    
    assert_difference('Node.count', 1) do
      put :create
    end
    
    assert_response :success
  end
  
  #in concession=mining preset:
  #k=website is ok
  #k=operator is restricted, but creation is okay
  def test_create_node_local_restricted_allowed
    basic_authorization(users(:public_user).email, "test")
    node_xml = "<osm><node id='23' lat='23.43' lon='23.32' changeset='#{changesets(:public_user_first_change).id}' version='32'><tag k='concession' v='mining' /><tag k='website' v='osm.org' /><tag k='operator' v='digalot inc' /></node></osm>"

    content(node_xml)
    assert_difference('Node.count', 1) do
      put :create
    end

    assert_response :success
  end
  
    
  def test_create_node_local_forbidden_other_user
    basic_authorization(users(:moderator_user).email, "test")
    node_xml = "<osm><node id='23' lat='23.43' lon='23.32' changeset='#{changesets(:moderator_user_first_change).id}' version='32'><tag k='concession' v='mining' /><tag k='website' v='osm.org' /><tag k='operator' v='digalot inc' /></node></osm>"

    content(node_xml)
    assert_difference('Node.count', 0) do
      put :create
    end

    assert_response :forbidden
    
    assert @response.body.include?('Permission denied')
    assert @response.body.include?('concession:mining')
  end

  #only members can delete
  def test_delete_allowed
    basic_authorization(users(:public_user).email, "test")
    
    content(nodes(:permissions_node).to_xml)
    delete :delete, :id => current_nodes(:permissions_node).id

    assert_response :success
  end
  
  #non members cannot delete
  def test_delete_forbidden
    basic_authorization(users(:moderator_user).email, "test")
    nodes(:permissions_node).changeset_id = changesets(:moderator_user_first_change).id
    
    content(nodes(:permissions_node).to_xml)
    delete :delete, :id => current_nodes(:permissions_node).id

    assert_response :forbidden
    
    assert @response.body.include?('Permission denied')
    assert @response.body.include?('concession:mining')
  end
  
  
  #members can_change a feature
  #adding a new tag
  def test_update_allowed_by_member
    basic_authorization(users(:public_user).email, "test")

    new_node = current_nodes(:permissions_node).to_xml
    new_tag = XML::Node.new "tag"
    new_tag['k'] = "tagtesting"
    new_tag['v'] = "valuetesting"
    new_node.find("//osm/node").first << new_tag
    
    content new_node
    put :update, :id => current_nodes(:permissions_node).id
    
    assert_response :success
  end
  
  #members cannot change concession=mining
  def test_update_global_forbidden_by_member
    basic_authorization(users(:public_user).email, "test")
    
    new_node = current_nodes(:permissions_node).to_xml
    new_node.find("//osm/node/tag[@k='concession']").first['v'] = "foo"
    
    content new_node
    put :update, :id => current_nodes(:permissions_node).id

    assert_response :forbidden
    assert @response.body.include?('Permission denied')
    assert @response.body.include?('concession:mining')
    
    #now change the key
    
    new_node = current_nodes(:permissions_node).to_xml
    new_node.find("//osm/node/tag[@k='concession']").first['k'] = "bar"
    
    content new_node
    put :update, :id => current_nodes(:permissions_node).id

    assert_response :forbidden
    assert @response.body.include?('Permission denied')
    assert @response.body.include?('concession:mining')
  end
  
  #and even nonmembers cannot change concession=mining
  def test_update_global_forbidden_by_nonmember
    basic_authorization(users(:moderator_user).email, "test")
    current_nodes(:permissions_node).changeset_id = changesets(:moderator_user_first_change).id
    new_node = current_nodes(:permissions_node).to_xml
    new_node.find("//osm/node/tag[@k='concession']").first['v'] = "foo"
    
    content new_node
    put :update, :id => current_nodes(:permissions_node).id

    assert_response :forbidden
    assert @response.body.include?('Permission denied')
    assert @response.body.include?('concession:mining')
    
  end
  
  #members can change website tag
  def test_update_local_unprotected_by_member
    basic_authorization(users(:public_user).email, "test")
    
    new_node = current_nodes(:permissions_node).to_xml
    new_node.find("//osm/node/tag[@k='website']").first['v'] = "foobar"
    
    content new_node
    put :update, :id => current_nodes(:permissions_node).id

    assert_response :success
  end
  
  #members cannot change operator tag
  def test_update_local_protected_by_member
    basic_authorization(users(:public_user).email, "test")
    
    new_node = current_nodes(:permissions_node).to_xml
    new_node.find("//osm/node/tag[@k='operator']").first['v'] = "foobar"
    
    content new_node
    put :update, :id => current_nodes(:permissions_node).id

    assert_response :forbidden  
    assert @response.body.include?('Permission denied')
    assert @response.body.include?('operator')
  end
 
  #nonmembers cannot change any tags
  def test_update_local_unprotected_by_nonmember
    basic_authorization(users(:moderator_user).email, "test")
    current_nodes(:permissions_node).changeset_id = changesets(:moderator_user_first_change).id
    new_node = current_nodes(:permissions_node).to_xml
    new_node.find("//osm/node/tag[@k='website']").first['v'] = "foobar"
    
    content new_node
    put :update, :id => current_nodes(:permissions_node).id

    assert_response :forbidden
    assert @response.body.include?('Permission denied')
    assert @response.body.include?('concession:mining')
  end  
  
  def test_user_in_two_groups
    us_group = groups(:american_drivers_group)
    us_group.users << users(:public_user)
    
    forest_preset = presets(:one)
    forest_preset.group = us_group
    forest_preset.save
    
    basic_authorization(users(:public_user).email, "test")
    node_xml = "<osm><node id='23' lat='23.43' lon='23.32' changeset='#{changesets(:public_user_first_change).id}' version='32'><tag k='natural' v='forest' /><tag k='website' v='osm.org' /></node></osm>"

    content(node_xml)
    
    assert_difference('Node.count', 1) do
      put :create
    end
    
    assert_response :success
    
    nodeid = @response.body
    checknode = Node.find(nodeid)
    assert_not_nil checknode
    assert 23.24, checknode.latitude
    assert_equal changesets(:public_user_first_change).id, checknode.changeset_id
    assert_equal true, checknode.visible
  end
  
  def test_update_allowed_by_member_two_groups
    us_group = groups(:american_drivers_group)
    us_group.users << users(:public_user)
    
    forest_preset = presets(:one)
    forest_preset.group = us_group
    forest_preset.save
    
    basic_authorization(users(:public_user).email, "test")
    
    new_node = current_nodes(:permissions_node).to_xml
    new_node.find("//osm/node/tag[@k='operator']").first['v'] = "foobar"
    
    content new_node
    put :update, :id => current_nodes(:permissions_node).id

    assert_response :forbidden  
    assert @response.body.include?('Permission denied')
    assert @response.body.include?('operator')
    
  end
  
  def test_update_allowed_by_member_two_groups_normal_member
    us_group = groups(:american_drivers_group)
    us_group.users << users(:public_user)
    
    forest_preset = presets(:one)
    forest_preset.group = us_group
    forest_preset.save
    
    basic_authorization(users(:public_user).email, "test")
    lat = rand(100)-50 + rand
    lon = rand(100)-50 + rand
    changeset = changesets(:public_user_first_change)
    # create a minimal xml file
    content("<osm><node lat='#{lat}' lon='#{lon}' changeset='#{changeset.id}'><tag k='natural' v='forest'/><tag k='name' v='foo'/></node></osm>")
    put :create
    # hope for success
    assert_response :success
    
    nodeid = @response.body
    checknode = Node.find(nodeid)
    assert_not_nil checknode
    
    new_node = checknode.to_xml
    new_node.find("//osm/node/tag[@k='name']").first['v'] = "foobar"
    
    content new_node
    put :update, :id =>checknode.id
    assert_response :success
  end
  
  def test_with_one_restricted_tag
    us_group = groups(:american_drivers_group)
    us_group.users << users(:public_user)
    
    forest_preset = presets(:one)
    forest_preset.group = us_group
    forest_preset.save
    
    field = Field.find(fields(:one))
    field.tag_key = "operator"
    field.save
    
    assert forest_preset.valid? 
    
    basic_authorization(users(:public_user).email, "test")
    lat = rand(100)-50 + rand
    lon = rand(100)-50 + rand
    changeset = changesets(:public_user_first_change)
    # create a minimal xml file
    content("<osm><node lat='#{lat}' lon='#{lon}' changeset='#{changeset.id}'><tag k='natural' v='forest'/><tag k='operator' v='foo'/></node></osm>")
    put :create
    # hope for success
    assert_response :success
  
  end
  
end