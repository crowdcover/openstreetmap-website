# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../test_helper'

class TileTest < ActiveSupport::TestCase
  fixtures :tiles
     
  test "allow blank description" do
    tile = Tile.new(:code=>"B",:keyid=>"base", :name=>"Base", :url => "http://tiles.osm.moabi.org/moabi_base/{z}/{x}/{y}.png", :description => "")
    assert tile.valid?
  end

  test "check empty tile fails" do
    tile = Tile.new
    assert !tile.valid?
    assert tile.errors[:code].any?
    assert tile.errors[:keyid].any?
    assert tile.errors[:name].any?
    assert tile.errors[:url].any?
  end
  
  test "basic tile succeeds" do
    tile = Tile.new(:code => "BB",:keyid => "basic", :name=>"Basic",
                     :url => "http://example.com/{z}/{y}/{z}.png")
    assert tile.valid?
  end
   
  test "base_layers scope" do
    basemaps = Tile.base_layers
    assert_not_nil basemaps
    assert_equal 3, basemaps.size
    assert basemaps[0] == Tile.find(1)
  end
  
  test "default base layers scope" do
    defaults = Tile.default_base_layers
    assert_equal 2, defaults.size
    assert defaults[0] == Tile.find(1)
  end
  
  test "overlay scope" do
    overlays = Tile.overlays
    assert overlays.size > 3
  end
  
  test "basemaps not in overlays" do
    base_one = Tile.find 1
    base_two = Tile.find 2
    overlay =  Tile.find 3
    
    overlays  = Tile.overlays
    assert overlays.include? overlay
    assert  overlays.include?(overlay)
    assert_equal  false, overlays.include?(base_one)
  end
  
end