require File.dirname(__FILE__) + '/../test_helper'

#
# Test cases for permissions
#

class PermissionTest < ActiveSupport::TestCase
  api_fixtures
  fixtures :groups, :users, :presets, :fields
  
  def test_restricted_tags
    restricted_tags = Preset.restricted_tags
    assert_equal ["concession" =>"mining"], restricted_tags
  end
  

  
end