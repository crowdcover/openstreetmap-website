require File.dirname(__FILE__) + '/../test_helper'

class PresetTest < ActiveSupport::TestCase
  fixtures :groups, :users, :presets, :fields
    
  def test_preset_count
    assert_equal 1, Preset.count
  end
  
  def test_new_from_json
    preset = Preset.new(:json => '{"geometry":["point","line","area"],"name":"new test","tags":{"natural":"forest"},"fields":["1","2"]}')
    assert preset.valid?
    preset.save
    assert_equal 2, Preset.count
    
    preset = Preset.last
    assert_equal "new test",preset.name
    assert_equal ["point","line","area"], preset.geometry
    assert_equal   preset.tags, {"natural"=>"forest"}
  end
  
  def test_update_json
    preset = presets(:one)
    
    preset.json  = '{"geometry":["point","line","area"],"name":"changed name","tags":{"natural":"forest"},"fields":["1","2"]}'
    preset.save
    
    assert_equal "changed name", preset.name
  end

end