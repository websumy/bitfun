class Post < ActiveRecord::Base
  attr_accessible :title, :body, :tag_list
  validates :body, presence: true

  # Tags
  acts_as_taggable

  has_many :fun, :as => :content, :dependent => :destroy
end