class Page < ActiveRecord::Base
  validates_presence_of :title
  validates_presence_of :slug
  validates_uniqueness_of :slug
end
