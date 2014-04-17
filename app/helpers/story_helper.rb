module StoryHelper
  
 
  def richtext_subset_area_tag(name, value, options = {})
    id = "#{name.to_s}"
    format = options.delete(:format) || "markdown"

    content_tag(:div, :id => "#{id}_container", :class => "richtext_container") do
      output_buffer << content_tag(:div, :id => "#{id}_content", :class => "richtext_content") do
        output_buffer << text_area_tag(name, value, options.merge("data-preview-url" => preview_url(:format => format)))
        output_buffer << content_tag(:div, "", :id => "#{id}_preview", :class => "richtext_preview richtext")
      end

      output_buffer << content_tag(:div, :id => "#{id}_help", :class => "richtext_help") do
        output_buffer << render("stories/#{format}_help")
        output_buffer << content_tag(:div, :class => "buttons") do
          output_buffer << submit_tag(I18n.t("site.richtext_area.edit"), :id => "#{id}_doedit", :class => "richtext_doedit deemphasize", :disabled => true)
          output_buffer << submit_tag(I18n.t("site.richtext_area.preview"), :id => "#{id}_dopreview", :class => "richtext_dopreview deemphasize")
        end
      end
    end
  end
  
  
  
end