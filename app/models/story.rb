class Story < ActiveRecord::Base
  include ActiveModel::Dirty
  # attribute names
  #["id", "title", "description", "latitude", "longitude", "zoom", "layers", "body", "filename", 
  # "layout", "language", "image_url", "user_id", "group_id", "created_at", "updated_at"]

  belongs_to :user
  belongs_to :group
  
  validates :title, :presence => true
  validates :title, :length => { :in => 5..250 }
  validates :title,  :uniqueness => true
  validates :description, :length => { :maximum => 1000 } 
  validates_numericality_of :latitude, :allow_nil => true, :greater_than_or_equal_to => -90, :less_than_or_equal_to => 90
  validates_numericality_of :longitude, :allow_nil => true, :greater_than_or_equal_to => -180, :less_than_or_equal_to => 180
  validate :validate_layers
  validate :validate_body
  validate :validate_permalink
 
  serialize :body
  serialize :layers
  
  before_create :make_filename
  after_save    :save_story_file
  after_destroy :delete_files
  #before_save :squish_text
  before_save :clean_attachments
  before_update :regen_file

  
  def self.default_params
    {
      "layers" => {},
      "body" => {
        "report" => {"title"=>"Report", 
          "sections"=>[{"title" => "", 
              "type" => "", 
              "text" => "", 
              "link" => "",
              "attachments" => []}
          ]
        }
      }
    }
  end
  
  #based on the RESTRICTED sanitize congfiguration, but allowing links and images
  def self.sanitize_config
    sanitize_config = {
      :elements => %w[b em i strong a img],
      :attributes => { 'a' => ['href', 'title'], 'img' => ['src', 'alt'] },
      :protocols => {'a'  => {'href' => ['http', 'https']},
                     'img' => {'src'  => ['http', 'https']}
      }
    }
    
    sanitize_config
  end
  
  def description
    RichText.new("markdown", read_attribute(:description))
  end
  
  
  #e.g  exploring-story
  def filename_slug
    self.title.parameterize
  end
   
  
  #e.g. moabi.org/exploring-story/en
  def permalink
    story_url = defined?(STORY_URL) ? STORY_URL : ""
    lang = self.language || "en"
    story_url + filename_slug + "/" + lang
  end
  
  
  #e.g 0100-04-04-exploring-story.md
  def make_filename
    time_stamp = Time.current.strftime("%Y-%m-%d")
    self.filename ="#{time_stamp}-#{filename_slug}.html"
  end
  
  
  #e.g. /var/site/_posts/projects/0100-04-04-exploring-story.md
  def story_file_path
    story_dir = defined?(STORY_DIR) ? STORY_DIR : ""
    File.join(story_dir, self.filename)
  end

  def attachments
    sections = body['report']['sections'] || []
    attachment_ids = sections.map { |section| section['attachments'] }.flatten.compact
    if attachment_ids.empty?
      attachment_ids
    else
      StoryAttachment.find(attachment_ids)
    end
  end


  def save_story_file
    logger.debug "render and save story file#{story_file_path}"
    @story = self
    @story.sanitize_text
    @attachments = Hash[ @story.attachments.map { |a| [a.id.to_s, a] } ]

    story_file = File.open(story_file_path,  "w+")
    template = File.open(File.join(Rails.root, "app/views/stories/story.md.erb")).read
    story_file.puts ERB.new(template, nil, "<>-").result( binding )
    story_file.close
  end

  
  def delete_files
    if File.exist?(story_file_path)
      logger.debug "deleting file #{story_file_path}"
      File.delete(story_file_path)
    end    
  end
  
  def regen_file
    if self.title_changed?
      delete_files
      make_filename
    end
  end
  
  #
  # Assuming the text has markdown markup - this renders to html first, and then sanitizes the resulting html
  # removes groups of whitespace and newlines etc and sanitizes for html using the config specified above
  #
  def sanitize_text
    self.description = Sanitize.clean(self.description.to_html, Story.sanitize_config).html_safe
    Story.default_params["body"].keys.each do | key |
      if self.body[key]["sections"]
        self.body[key]["sections"].each do | section |
          if section["text"]
            text = RichText.new("markdown", section["text"]).to_html
            section["text"] = Sanitize.clean(text, Story.sanitize_config).html_safe
          end
        end
      end
    end
  end
  
  def squish_text
    self.description = self.description.squish
    Story.default_params["body"].keys.each do | key |
      if self.body[key]["sections"]
        self.body[key]["sections"].each do | section |
          section["text"] = section["text"].squish if section["text"]
        end
      end
    end

  end

  def clean_attachments
    Story.default_params["body"].keys.each do | key |
      if self.body[key]["sections"]
        self.body[key]["sections"].each do | section |
          if section['attachments']
            section['attachments'] = section['attachments'].reject { |sid| sid.empty? }
          end
        end
      end
    end
  end

  def validate_layers
    if layers.empty?  || (layers.size == 1 && layers[0].blank?)
      errors.add(:layers, "are empty and have not been chosen")
    end  
  end
  
  def validate_body
    default_keys = Story.default_params["body"].keys.sort
    if body.keys.nil?
      errors.add(:body, "needs to be in the correct format")
    end
    if body.keys.sort != default_keys
      errors.add(:body, "should have #{default_keys}")
    end
  end
  

  
  def validate_permalink
    if self.new_record?
      titles = Story.select("title").collect{|t| t.title.parameterize}
    else
      titles = Story.select("title").where(["id != ?", self.id]).collect{|t| t.title.parameterize}
    end
    
    if titles.include?(self.filename_slug)
      errors.add(:title, "should be unique")
    end
  end
  
  
  
end
