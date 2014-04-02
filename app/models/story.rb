class Story < ActiveRecord::Base
  # attribute names
  #["id", "title", "description", "latitude", "longitude", "zoom", "layers", "body", "filename", 
  # "layout", "language", "image_url", "user_id", "group_id", "created_at", "updated_at"]

  belongs_to :user
  belongs_to :group
  
  validates :title, :presence => true
  validates :title, :length => { :in => 5..250 }
  validates :description, :length => { :maximum => 1000 } 
  validates_numericality_of :latitude, :allow_nil => true, :greater_than_or_equal_to => -90, :less_than_or_equal_to => 90
  validates_numericality_of :longitude, :allow_nil => true, :greater_than_or_equal_to => -180, :less_than_or_equal_to => 180 
 
  before_create :make_filename
  after_save    :save_story_file
  after_destroy :delete_files
  
   
  
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
    self.filename ="#{time_stamp}-#{filename_slug}.md"
  end
  
  
  #e.g. /var/site/_posts/projects/0100-04-04-exploring-story.md
  def story_file_path
    story_dir = defined?(STORY_DIR) ? STORY_DIR : ""
    File.join(story_dir, self.filename)
  end
  
        
  def save_story_file
    logger.debug "render and save story file#{story_file_path}"
    @story = self
   
    story_file = File.open(story_file_path,  "w+")
    template = File.open(File.join(Rails.root, "app/views/stories/story.md.erb")).read
    story_file.puts ERB.new(template).result( binding )
    story_file.close
  end

  
  def delete_files
    if File.exist?(story_file_path)
      logger.debug "deleting file #{story_file_path}"
      File.delete(story_file_path)
    end    
  end
  
  
end
