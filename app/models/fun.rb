class Fun < ActiveRecord::Base
  attr_accessible :title, :content_attributes, :content_type

  # Kaminari pagination config
  paginates_per 3

  # Associations
  belongs_to :user
  belongs_to :content, :polymorphic => true, :dependent => :destroy
  accepts_nested_attributes_for :content, :allow_destroy => true

  acts_as_votable

  def attributes=(attributes = {})
    self.content_type = attributes[:content_type]
    super
  end

  def content_attributes=(attributes)
    content = self.content_type.constantize.find_or_initialize_by_id(self.content_id)
    content.attributes = attributes
    self.content = content
  end

  # Validation
  validates :user_id, :presence => true
  validates :title, :presence => true

  # Scopes
  scope :images, where(content_type: "Image")
  scope :videos, where(content_type: "Video")
  scope :posts, where(content_type: "Post")

  def total_shows
    self.cached_shows
  end

  def total_likes
    self.cached_votes_total
  end

  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM #{:user_relationships} WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids})", user_id: user.id)
  end

  def self.sorting (order_column, interval)
    order_column = Fun.column_names.include?(order_column) ? order_column : "created_at"
    interval = %w(week month year).include?(interval) ? interval: "year"
    where(created_at: Time.now - 1.send(interval) .. Time.now).order(order_column + " DESC")
  end

end