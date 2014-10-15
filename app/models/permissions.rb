module Permissions
  
  #check that a user is able to create, update or delete elements
  #will raise a APIForbiddenError error 
  
  #called when updating an element
  def check_update_permissions(old, new, user)
    active_presets = Preset.active
    user_permitted_tags = user.group_presets_tags
    
    active_presets.each do | preset |
      restricted_key = preset.tags.keys.first
      restricted_val = preset.tags[preset.tags.keys.first]
      
      if (new.tags.key?(restricted_key) && new.tags[restricted_key] == restricted_val) || (old.tags.key?(restricted_key) && old.tags[restricted_key] == restricted_val)
        
        if (new.tags[restricted_key] != old.tags[restricted_key])
          raise OSM::APIForbiddenError.new("Permission denied, not allowed to update - element uses #{preset.tags} restricted tags")
        end
        
        #top level tags which define the feature
        unless user_permitted_tags.include? preset.tags
          raise OSM::APIForbiddenError.new("Permission denied, not allowed to update - element uses #{preset.tags} restricted tags")
        end
        
        #within the feature, allowed to edit the fields?
        protected_fields = preset.fields.with_protection.pluck(:tag_key).flatten
        
        protected_fields.each do | protected_field |
          
          #they have to both be there, or both not be there
          if (new.tags.key?(protected_field) && old.tags.key?(protected_field)) || !(new.tags.key?(protected_field) && old.tags.key?(protected_field))
            #now check value
            if new.tags.key?(protected_field) && (new.tags[protected_field] != old.tags[protected_field])
              raise OSM::APIForbiddenError.new("Permission denied, not allowed to update element has #{protected_field} protected field")
            end
            
          else
            raise OSM::APIForbiddenError.new("Permission denied, not allowed to update element has #{protected_field} protected field")
          end
          
        end
        
        
      end #if in a restricted feature
      
    end #active presets
  end

  
  #only group members allowed to delete a feature
  def check_delete_permissions(old, new, user)
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
        
      end
      
    end
  end
  
  #
  # Called by create
  # Group members cah create new features
  #
  def check_create_permissions(new, user)
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

          
      end #if in a restricted feature
      
    end #active presets

  end
  
  
end

