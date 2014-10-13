module Permissions
  
  #check that a user is able to create, update or delete elements
  #will raise a APIForbiddenError error 
  
  #called when updating an element
  def check_update_permissions(old, new, user)
   # puts "check permissions, update"
   # puts "new", new.inspect
   # puts "old", old.inspect
  end
  
  
  #
  # Called by create and delete
  #
  def check_permissions(new, user)
    active_presets = Preset.active
    user_permitted_tags = user.group_presets_tags

    active_presets.each do | preset |
      restricted_key = preset.tags.keys.first
      restricted_val = preset.tags[preset.tags.keys.first]

      if new.tags.key?(restricted_key) && new.tags[restricted_key] == restricted_val
        
        #top level tags which define the feature
        unless user_permitted_tags.include? preset.tags
          raise OSM::APIForbiddenError.new("Permission denied, not allowed to create - element uses #{preset.tags} restricted tags")
        end
        
        #within the feature, allowed to edit the fields?
        protected_fields = preset.fields.with_protection.pluck(:tag_key).flatten

        protected_fields.each do | protected_field |

          if new.tags.key?(protected_field)
            raise OSM::APIForbiddenError.new("Permission denied, not allowed to create - element has #{protected_field} protected field")
          end
        end

          
      end
      
    end
    

  end
  
  
end