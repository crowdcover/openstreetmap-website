class GroupMembership < ActiveRecord::Base
  belongs_to :group
  belongs_to :user
  
  scope :active, -> { where(:status => ["active"]) }
  scope :pending, -> { where(:status => ["invited"]) }

  validates_uniqueness_of :user_id, :scope => :group_id
  
  after_initialize :set_defaults

  ##
  # a simple role system; possible to expand in the future
  module Roles
    LEADER = "Leader"
    MEMBER = ""

    ALL_ROLES = [MEMBER, LEADER]
  end

  #attr_accessible :role

  def set_role(new_role)
    if Roles::ALL_ROLES.include? new_role
      return update_attribute(:role, new_role)
    else
      return false
    end
  end

  def has_role?(test_role)
    role == test_role
  end

  def is_a_leader?
    has_role? Roles::LEADER
  end
  
  def active?
    ["active"].include? self.status
  end
  
  def self.create_token
    OSM::make_token()
  end
  
  private

  def set_defaults
    self.invite_token = GroupMembership.create_token if self.invite_token.blank?
    self.status = "invited" if self.status.blank?
  end
  
end
