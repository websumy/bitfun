class Image < ActiveRecord::Base
  mount_uploader :file, ImageUploader
  attr_accessible :title, :file, :remote_file_url, :url, :tag_list

  # Validation
  # require 'file_size_validator'
  validates :file, presence: true, file_size: { maximum: 15.megabytes.to_i }
  validates :remote_file_url, format: /(https?:\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix, allow_blank: true
  validates :title, length: { minimum: 3 }, allow_blank: true
  validates_integrity_of :file
  validates_processing_of :file
  validate :check_image

  # Tags
  acts_as_taggable

  def attributes=(attributes = {})
    self.url = attributes[:remote_file_url]
    super
  end

  has_many :fun, as: :content, dependent: :destroy

  def exist_gif_thumb?
    self.file.gif.file.exists?
  end

  private

  def check_image
    errors.add(:url, 'Cat not add this file') unless file.present?
  end
end
