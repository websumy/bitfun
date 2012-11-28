class Image < ActiveRecord::Base
  attr_accessible :file, :remote_file_url, :url, :tag_list

  # Tags
  acts_as_taggable

  has_one :fun, :as => :content, :dependent => :destroy
end
