class Image < ActiveRecord::Base
  mount_uploader :file, ImageUploader
  attr_accessible :file, :remote_file_url, :url, :tag_list

  # Validation
  require 'file_size_validator'
  require 'uri_validator'
  validates :file, presence: true, file_size: {maximum: 1.megabytes.to_i}
  validates :remote_file_url,
            uri: {
                format: /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix,
                unless: :file?
            }
  validates_integrity_of :file
  validates_processing_of :file

  # Tags
  acts_as_taggable

  def attributes=(attributes = {})
    self.url = attributes[:remote_file_url]
    super
  end

  has_many :fun, :as => :content, :dependent => :destroy
end
