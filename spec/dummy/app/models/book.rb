class Book < ActiveRecord::Base
  has_many :chapters, :dependent => :destroy

  validates_uniqueness_of :name
end
