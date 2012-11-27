class Post < ActiveRecord::Base
  attr_accessible :body
  validates :body, presence: true

  has_one :fun, :as => :content, :dependent => :destroy
end