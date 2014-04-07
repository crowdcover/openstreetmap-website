class Tile < ActiveRecord::Base
   scope :base_layers, -> { where.not(:base_layer => nil) }
   scope :default_base_layers, -> { base_layers.where(:base_layer => "default")}
   scope :overlays, -> {where(:base_layer => nil)}
end
