require File.dirname(__FILE__) + '/../../test_helper'

#
# Majority of permissions logic is in the permissions_node_controller_test
#

class PermissionsRelationControllerTest < ActionController::TestCase
  tests RelationController
  
  api_fixtures
  fixtures :groups, :group_memberships, :users, :presets, :fields, :nodes

  def test_create_normal
    basic_authorization(users(:public_user).email, "test")
    
    changeset_id = changesets(:public_user_first_change).id

    # create an relation without members
    content "<osm><relation changeset='#{changeset_id}'><tag k='test' v='yes' /></relation></osm>"
    put :create
    # hope for success
    assert_response :success
    # read id of created relation and search for it
    relationid = @response.body
    checkrelation = Relation.find(relationid)
    assert_not_nil checkrelation
  end

    
  def test_create_global_allowed
    basic_authorization users(:public_user).email, "test"
    
    changeset_id = changesets(:public_user_first_change).id

    # create an relation without members
    content "<osm><relation changeset='#{changeset_id}'><tag k='concession' v='mining' /></relation></osm>"
    put :create
    # hope for success
    assert_response :success
    # read id of created way and search for it
    relationid = @response.body
    checkrelation = Relation.find(relationid)
    assert_not_nil checkrelation
  end
  
  def test_create_global_forbidden
    basic_authorization(users(:moderator_user).email, "test")

    changeset_id = changesets(:moderator_user_first_change).id
    content "<osm><relation changeset='#{changeset_id}'><tag k='concession' v='mining' /></relation></osm>"
    put :create

    assert_response :forbidden
    
    assert @response.body.include?('Permission denied')
    assert @response.body.include?('concession:mining')
  end

end