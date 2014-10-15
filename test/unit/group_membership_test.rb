# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../test_helper'

class GroupMemberShipTest < ActiveSupport::TestCase
  fixtures :groups, :users, :group_memberships
  
  def test_membersip_count
    assert_equal 3, GroupMembership.count
  end
  
  def test_roles
    m = group_memberships(:public_british)
    assert m.has_role?(GroupMembership::Roles::LEADER)
    assert m.has_role?("Leader")
    assert m.is_a_leader?
  end
  
  def test_set_role
    m = group_memberships(:second_public_british)
    assert_equal false, m.has_role?(GroupMembership::Roles::LEADER)
    
    m.set_role("Leader")
    
    assert m.has_role?(GroupMembership::Roles::LEADER)
    assert m.is_a_leader?
  end
  
  def test_set_incorrect_role
    m = group_memberships(:second_public_british)
    assert_equal false, m.has_role?(GroupMembership::Roles::LEADER)
    
    m.set_role("Admin")
    
    assert_equal false, m.has_role?("Admin")
  end
  
  def test_active
    m = group_memberships(:public_british)
    assert m.active?
  end
  
  def test_token
    invite_token = GroupMembership.create_token
    assert_not_nil invite_token
  end
  
  def test_defaults
    us_group = groups(:american_drivers_group)
    us_group.users << users(:public_user)
    
    assert_not_nil us_group.group_memberships.find_by_user_id(users(:public_user).id).invite_token
    
    assert "invited", us_group.group_memberships.find_by_user_id(users(:public_user).id).status
  end
  
end