# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < ActiveSupport::TestCase
  api_fixtures
  fixtures :groups, :users

  def test_group_count
    assert_equal 2, Group.count
  end

  def test_group_membership
    uk_group = Group.find(1)
    us_group = Group.find(2)
    first_user = User.find(1)
    second_user = User.find(2)

    uk_group.users << first_user
    uk_group.users << second_user
    us_group.users << second_user

    assert arrays_are_equal?(uk_group.users.map(&:id), [first_user.id, second_user.id])
    assert arrays_are_equal?(us_group.users.map(&:id), [second_user.id])
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
    uk_group = Group.find(1)
    uk_group.users << users(:normal_user)
    uk_group.users << users(:public_user)
    uk_group.add_leader(users(:normal_user))
    
    assert_equal uk_group.leaders, [users(:normal_user)]
    assert uk_group.leadership_includes?(users(:normal_user))
    assert_equal false, uk_group.leadership_includes?(users(:public_user))
    
    us_group = Group.find(2)
    us_group.users << users(:public_user)
    us_group.add_leader(users(:public_user))
    assert_equal false, uk_group.leadership_includes?(users(:public_user))
    assert  us_group.leadership_includes?(users(:public_user))
  end
  
private

  def arrays_are_equal?(a, b)
    a.sort.uniq == b.sort.uniq
  end
end
