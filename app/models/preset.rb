class Preset < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'user_id'
  belongs_to :group
  
  has_many :fields
  
  serialize :geometry
  serialize :tags
  
  scope :available, -> { where(:group_id => nil) }
    
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
    if self.previous_changes.keys.include? "json"
      j = ActiveSupport::JSON.decode(json)
      fields = j["fields"]
      fields.each do | field_id |
        begin
          f = Field.find(field_id.to_i)
          f.preset = self
          f.save
        rescue ActiveRecord::RecordNotFound
          puts "Field #{f} not found"
        end
      end
    end
  end
  
end
