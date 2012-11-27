class Image < ActiveRecord::Base
  attr_accessible :image, :url

  has_one :fun, :as => :content, :dependent => :destroy
end
