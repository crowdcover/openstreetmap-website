require File.dirname(__FILE__) + '/../test_helper'

class PresetTest < ActiveSupport::TestCase
  fixtures :groups, :users, :presets, :fields
      
  def test_new_from_json
    preset = Preset.new(:json => '{"geometry":["point","line","area"],"name":"new test","tags":{"natural":"lake"},"fields":["1","2"]}')
    assert preset.valid?
    assert_difference('Preset.count', 1) do
      preset.save
    end
    
    preset = Preset.last
    assert_equal "new test",preset.name
    assert_equal ["point","line","area"], preset.geometry
    assert_equal   preset.tags, {"natural"=>"lake"}
  end
  
  def test_update_json
    preset = presets(:one)
    
    preset.json  = '{"geometry":["point","line","area"],"name":"changed name","tags":{"natural":"forest"},"fields":["1","2"]}'
    preset.save
    
    assert_equal "changed name", preset.name
  end
  
  def test_group
    preset = presets(:two)
    
    assert_equal groups(:british_cyclists_group), preset.group
    assert_equal groups(:british_cyclists_group).preset, preset
  end
  
  def test_restricted_tags  
    restricted_tags = Preset.restricted_tags
    assert_equal ["concession" =>"mining"], restricted_tags
  end
  
  #cannot have two presets with the same tags attribute
  def test_validate_uniqueness
   #Can't figure out how to correctly represent an ActiveRecord:Store in a yaml fixture, so just force the preset to save it in the correct format via:
   one_preset = Preset.find(presets(:one).id)
   one_preset.save
     
   preset = Preset.new(:json => '{"geometry":["point","line","area"],"name":"new test","tags":{"natural":"forest"},"fields":["1","2"]}')
   assert_raise OSM::APIDuplicatePresetTagsError do
     preset.valid?
   end

  end

end