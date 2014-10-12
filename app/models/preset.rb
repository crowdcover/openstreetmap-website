class Preset < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'user_id'
  belongs_to :group
  
  has_many :fields
  
  serialize :geometry
  serialize :tags
  
  scope :available, -> { where(:group_id => nil) }
  scope :active,  -> { where.not(:group_id => nil)}
    
  before_save :deserialize_json
  after_save :update_field_joins
  
  #typical json
  #{"geometry":["point","line","area"],"name":"Test Mines","tags":{"Site":"Company"},"fields":["1","2"]}
  
  def name_with_group
    if group_id
      "#{name} (in Group:#{group_id})"
    else
      name
    end
  end
  
  # only presets assinged to groups can be used
  def self.restricted_tags
    active.map{|p| p.tags }
  end
  
  private
  
  #
  # if there is new json it will overwrite attributes
  #
  def deserialize_json
    if json_changed?
      j = ActiveSupport::JSON.decode(json_change[1])
      self.name = j["name"]
      self.geometry = j["geometry"]
      self.tags = j["tags"]
    end

  end
  
  # if the json was changed, then...
  # the json has the fields in there so we need to update the fields to point to this preset
  #
  def update_field_joins
      j = ActiveSupport::JSON.decode(json)
      fields = j["fields"]
      fields.each do | field_id |
        begin
          f = Field.find(field_id.to_i)
          f.preset_id = self.id
          f.save
        rescue ActiveRecord::RecordNotFound
          puts "Field #{f} not found"
        end
      end
  end
  
end
