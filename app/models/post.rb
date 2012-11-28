class Post < ActiveRecord::Base
  attr_accessible :body, :tag_list
  validates :body, presence: true

  # Tags
  acts_as_taggable

  has_one :fun, :as => :content, :dependent => :destroy
end