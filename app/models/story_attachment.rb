class StoryAttachment < ActiveRecord::Base
  has_attached_file :image,
    :styles => { :large => "1024x768#", :small => "320x240#" },
    :default_url => "/assets/:class/:attachment/:style.gif",
    :default_style => :large,
    :convert_options => {
      :large => '-strip',
      :small => '-strip'
    }

  before_post_process :image?

  validates_attachment_content_type :image,
    :content_type => /\Aimage\/.*\Z/

  def serializable_hash(options = nil)
    {
      :id => id,
      :image => Hash[
        image.styles.map do |name, style|
          [ name, { :geometry => style.geometry, :url => style.attachment.url(name) } ]
        end
      ]
    }
  end

  def image?
    (image_content_type =~ /\Aimage\/.*\Z/) != nil
  end

end