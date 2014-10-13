class Field < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'user_id'
  belongs_to :preset
    
  scope :with_protection, -> { where(protect: true) }
  
  before_save :deserialize_json
  after_initialize :set_defaults
  #typical json #{"type":"textarea","key":"source","label":"Source"}
  #maps to element, tag_key, label
  
  #
  # if there is new json it will overwrite attributes
  #
  def deserialize_json
    if json_changed?
      j = ActiveSupport::JSON.decode(json_change[1])
      self.element = j["type"]
      self.tag_key = j["key"]
      self.label = j["label"]
    end

  end
  
  def set_defaults
    self.protect = false unless self.attribute_present?(:protect)
  end
  
end
