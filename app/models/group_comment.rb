class GroupComment < ActiveRecord::Base
  belongs_to :group
  belongs_to :author, :class_name => "User", :foreign_key => :user_id
  belongs_to :parent, :class_name => 'GroupComment', :foreign_key => :parent_id
  has_many :children, :class_name => 'GroupComment', :foreign_key => :parent_id
  
  scope :visible, ->  { where(:visible => true) }
  
  validates_uniqueness_of :id
  validates_associated :group
  validates_associated :author
  validates :visible, :inclusion => { :in => [true,false] }
  
  after_initialize :prepare_hidden
  
  def grandparent(next_parent=nil)
    next_parent = next_parent || parent
    if next_parent
      if next_parent.parent
        grandparent(next_parent.parent)
      else
        return next_parent
      end
    end
  end
  
  def is_root?
    parent_id.nil?
  end
  
  def prepare_hidden
    unless self.visible?
      self.title = "Comment Deleted"
      self.body = "comment deleted"
    end
  end
  
end