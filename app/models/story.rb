class Story < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  
  validates :title, :presence => true
  validates :title, :length => { :in => 3..250 }
  validates :description, :length => { :maximum => 1000 }
  validates_numericality_of :latitude, :allow_nil => true,
                            :greater_than_or_equal_to => -90, :less_than_or_equal_to => 90
  validates_numericality_of :longitude, :allow_nil => true,
                            :greater_than_or_equal_to => -180, :less_than_or_equal_to => 180
  #also body

  def description
    RichText.new("markdown", read_attribute(:description))
  end

  
end
