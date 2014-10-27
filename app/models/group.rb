class Group < ActiveRecord::Base
  has_many :group_memberships, :dependent => :destroy
  has_many :users, :through => :group_memberships
  has_many :active_users, -> {where(:group_memberships => {:status => "active"})},  :source => :user, :through => :group_memberships
  has_many :invited_users, -> {where(:group_memberships => {:status => "invited"})},  :source => :user, :through => :group_memberships
 
  
  has_many :leaders,
            -> {where(:group_memberships => {:role => GroupMembership::Roles::LEADER})},
           :class_name => 'User', 
           :source => :user, 
           :through => :group_memberships
  has_many :stories, :dependent => :nullify
  has_one  :preset, :dependent => :nullify
  has_many :comments, -> { where(:visible => true) }, :class_name => "GroupComment", :dependent => :destroy
  
  has_attached_file :image,
    :default_url => "/assets/:class/:attachment/:style.png",
    :styles => { :large => "100x100>", :small => "50x50>" }
  
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  accepts_nested_attributes_for :group_memberships, :allow_destroy => true

  validates :title, :length => { :in => 3..250 }
  validates :description, :length => { :in => 2..1000 }

  after_initialize :set_defaults
  
  def leadership_includes?(user)
    group_memberships.where(:role => GroupMembership::Roles::LEADER, :user_id => user.id).count > 0
  end

  def description
    RichText.new(read_attribute(:description_format), read_attribute(:description))
  end
  
  def add_leader(user)
    group_membership = group_memberships.find_by_user_id(user.id)
    if group_membership
      group_membership.set_role(GroupMembership::Roles::LEADER)
    end
  end
  
  def root_comments
    self.comments.where(:parent_id => nil)
  end

private
  def set_defaults
    self.description_format = "markdown" unless self.attribute_present?(:description_format)
  end
end
