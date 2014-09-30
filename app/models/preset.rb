class Preset < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'user_id'
  belongs_to :group
  
  scope :available, -> { where(:group_id => nil) }
    
  after_initialize :decode_json
  
  #{"geometry":["point","line","area"],"name":"Test Mines","tags":{"Site":"Company"},"fields":[]}
  attr_reader :name
  
  def name_with_group
    if group_id
      "#{name} (in Group:#{group_id})"
    else
      name
    end
  end
  
  private
  
  def decode_json
    j = ActiveSupport::JSON.decode(json)
    @name = j["name"]
  end
  
end
