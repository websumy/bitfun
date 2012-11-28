class Image < ActiveRecord::Base
  attr_accessible :image, :url, :tag_list

      # Tags
  acts_as_taggable

  has_one :fun, :as => :content, :dependent => :destroy
end
