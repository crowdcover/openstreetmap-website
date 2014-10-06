class Field < ActiveRecord::Base
    belongs_to :user, :foreign_key => 'user_id'
    belongs_to :preset
    
    #typical json #{"type":"textarea","key":"source","label":"Source"}
  
end
