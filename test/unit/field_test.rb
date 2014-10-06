require File.dirname(__FILE__) + '/../test_helper'

class FieldTest < ActiveSupport::TestCase
  fixtures :groups, :users, :presets, :fields
  
  def test_new_from_json
    field = Field.new(:json => '{"type":"textarea","key":"name","label":"Name"}')
    assert field.valid?
    field.save

    field = Field.last
    assert_equal  "textarea",field.element
    assert_equal  "name", field.tag_key
    assert_equal  "Name", field.label
    assert_equal false, field.protect
  end
  
  def test_default_protect
    field = fields(:one)
    assert_equal false, field.protect
    
    field.protect = true
    field.save
    assert_equal true, field.protect
  end
  
end