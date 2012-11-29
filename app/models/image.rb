class Image < ActiveRecord::Base
  attr_accessible :file, :remote_file_url, :url, :tag_list

  mount_uploader :file, ImageUploader

  # Tags
  acts_as_taggable

  def attributes=(attributes = {})
    self.url = attributes[:remote_file_url]
    super
  end

  has_many :fun, :as => :content, :dependent => :destroy
end
