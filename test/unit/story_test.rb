# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../test_helper'

class StoryTest < ActiveSupport::TestCase
  fixtures :groups, :users, :stories
  
  test "story count" do
    assert_equal 2, Story.count
  end
  
  test "group story" do
    group = Group.find 1
    story = Story.find 2
    assert_equal group, story.group
  end
  
  test "allow blank description" do
    story = Story.new(:title => "a new story", :description => "")
    assert story.valid?
  end

end
