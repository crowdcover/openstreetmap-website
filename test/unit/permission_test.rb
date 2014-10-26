require File.dirname(__FILE__) + '/../test_helper'

#
# Test cases for permissions
#

class PermissionTest < ActiveSupport::TestCase
  api_fixtures
  fixtures :groups, :group_memberships, :users, :presets, :fields, :nodes
  
  def test_restricted_tags
    restricted_tags = Preset.restricted_tags
    assert_equal ["concession" =>"mining"], restricted_tags
  end
  
  def test_create_node
    node_xml = "<osm><node id='23' lat='23.43' lon='23.32' changeset='#{changesets(:public_user_first_change).id}' version='32'><tag k='key' v='value' /></node></osm>"

    node = Node.from_xml(node_xml, true)
    
    assert_nothing_raised(OSM::APIForbiddenError) {
      node.create_with_history(users(:public_user))
    }
  end
  
  def test_create_node_global_allowed
    node_xml = "<osm><node id='23' lat='23.43' lon='23.32' changeset='#{changesets(:public_user_first_change).id}' version='32'><tag k='concession' v='mining' /><tag k='name' v='a value' /></node></osm>"

    node = Node.from_xml(node_xml, true)
    
    assert_nothing_raised(OSM::APIForbiddenError) {
      node.create_with_history(users(:public_user))
    }
  end
  
  def test_create_node_global_forbidden
    node_xml = "<osm><node id='23' lat='23.43' lon='23.32' changeset='#{changesets(:moderator_user_first_change).id}' version='32'><tag k='concession' v='mining' /><tag k='name' v='a value' /></node></osm>"

    node = Node.from_xml(node_xml, true)
    
    assert_raise(OSM::APIForbiddenError) {
      node.create_with_history(users(:moderator_user))
    }
  end

  #in concession=mining preset:
  #k=website is ok
  #k=operator is restricted
  def test_create_node_local_allowed
    node_xml = "<osm><node id='23' lat='23.43' lon='23.32' changeset='#{changesets(:public_user_first_change).id}' version='32'><tag k='concession' v='mining' /><tag k='website' v='osm.org' /></node></osm>"

    node = Node.from_xml(node_xml, true)
    
    assert_nothing_raised(OSM::APIForbiddenError) {
      node.create_with_history(users(:public_user))
    }
  end
  
  #in concession=mining preset:
  #k=website is ok
  #k=operator is restricted
  def test_create_node_local_allowed_more
    node_xml = "<osm><node id='23' lat='23.43' lon='23.32' changeset='#{changesets(:public_user_first_change).id}' version='32'><tag k='concession' v='mining' /><tag k='website' v='osm.org' /><tag k='operator' v='digalot inc' /></node></osm>"

    node = Node.from_xml(node_xml, true)
    
    assert_nothing_raised(OSM::APIForbiddenError) {
      node.create_with_history(users(:public_user))
    }
  end
  
  #another user in the allowed group
  def test_create_node_local_allowed_other_user
    node_xml = "<osm><node id='23' lat='23.43' lon='23.32' changeset='#{changesets(:second_public_user_first_change).id}' version='32'><tag k='concession' v='mining' /><tag k='website' v='osm.org' /><tag k='operator' v='digalot inc' /></node></osm>"

    node = Node.from_xml(node_xml, true)

    assert_nothing_raised(OSM::APIForbiddenError) {
      node.create_with_history(users(:second_public_user))
    }
  end
  
    #another user in the allowed group
  def test_create_node_local_forbidden
    node_xml = "<osm><node id='23' lat='23.43' lon='23.32' changeset='#{changesets(:moderator_user_first_change).id}' version='32'><tag k='concession' v='mining' /><tag k='website' v='osm.org' /><tag k='operator' v='digalot inc' /></node></osm>"

    node = Node.from_xml(node_xml, true)

    assert_raise(OSM::APIForbiddenError) {
      node.create_with_history(users(:moderator_user))
    }
  end
    
end
