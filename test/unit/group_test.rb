# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < ActiveSupport::TestCase
  api_fixtures
  fixtures :groups, :users, :group_memberships

  def test_group_count
    assert_equal 2, Group.count
  end

  def test_group_membership
    uk_group = groups(:british_cyclists_group)
    us_group = groups(:american_drivers_group)
    first_user = users(:public_user)
    second_user = users(:second_public_user)
    third_user =  users(:moderator_user)

    us_group.users << second_user

    assert arrays_are_equal?(uk_group.users.map(&:id), [first_user.id, second_user.id])
    assert arrays_are_equal?(us_group.users.map(&:id), [second_user.id, third_user.id])
    assert arrays_are_equal?(first_user.groups.map(&:id), [uk_group.id])
    assert arrays_are_equal?(second_user.groups.map(&:id), [uk_group.id, us_group.id])
  end
  
  def test_group_creation
    new_group = Group.new(:title => "a new group", :description => "worldwide cycling society")
    new_group.users << users(:normal_user)
    
    assert new_group.valid?
    new_group.save!
     
    assert_equal new_group.users, [users(:normal_user)]
    
    new_group.users << users(:public_user)
    assert_equal new_group.users, [users(:normal_user), users(:public_user)]   
  end
  
  def test_group_leader
    uk_group = groups(:british_cyclists_group)
 
    
    assert_equal uk_group.leaders, [users(:public_user)]
    assert uk_group.leadership_includes?(users(:public_user))
    assert_equal false, uk_group.leadership_includes?(users(:second_public_user))
    
    us_group = groups(:american_drivers_group)
    us_group.users << users(:second_public_user)
    us_group.add_leader(users(:second_public_user))
    assert_equal false, uk_group.leadership_includes?(users(:second_public_user))
    assert  us_group.leadership_includes?(users(:second_public_user))
  end
  
private

  def arrays_are_equal?(a, b)
    a.sort.uniq == b.sort.uniq
  end
end
