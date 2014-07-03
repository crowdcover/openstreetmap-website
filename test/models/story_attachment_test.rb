require File.dirname(__FILE__) + '/../test_helper'
require 'pry-debugger'

class StoryAttachmentTest < ActiveSupport::TestCase

  teardown do
    @attachment.image.clear
    @attachment.save
  end

  test "image file saves if valid" do
    image = File.new('test/fixtures/story_attachments/user.png')
    @attachment = StoryAttachment.new(:image => image)
    assert @attachment.save == true
  end

  test "invalid if not image" do
    image = File.new('test/fixtures/users.yml')
    @attachment = StoryAttachment.new(:image => image)
    assert @attachment.save == false
  end

end
