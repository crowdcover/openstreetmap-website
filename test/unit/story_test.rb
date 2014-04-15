# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../test_helper'

class StoryTest < ActiveSupport::TestCase
  fixtures :groups, :users, :stories, :tiles
  
  setup do
    Object.const_set("STORY_DIR", "/tmp")
  end
  
  test "story count" do
    assert_equal 2, Story.count
  end
  
  test "group story" do
    group = Group.find 1
    story = Story.find 2
    assert_equal group, story.group
  end
  
  test "allow blank description" do
    story = Story.new({:title => "foobar", :description => "", :layout => "project", 
        :language => "en", :image_url => "http://example.com/image.png",
        :layers => ["energy"], 
        :body => {"layers"=>{"title"=>"Layers", "sections"=>[{"title"=>"layer title", "text"=>"layer description"}]}, 
          "report"=>{"title"=>"Report", "sections"=>[{"title"=>"first section", "text"=>"some text"}]}, 
          "sites"=>{"title"=>"Locations", "sections"=>[{"title"=>"locations", "text"=>"some text", 
                "links"=>["title"=>"", "text"=>"", "link"=>""]
              }]}
        }
      }
    )
    assert story.valid?
  end
  
  test "squishes descriptions" do
    @story = Story.find 1
    orig_description  = "Description with a     \n   \t  new line and spaces"
    @story.description = orig_description
    assert_match(/\n/, @story.description)
    @story.save
    @story.reload
    assert_not_equal @story.description, orig_description
    assert_no_match(/\n/, @story.description)
    assert_equal "Description with a new line and spaces", @story.description
  end
  
end
