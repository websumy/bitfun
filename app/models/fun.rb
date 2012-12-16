class Fun < ActiveRecord::Base
  attr_accessible :title, :content_attributes, :content_type, :author_id

  # Kaminari pagination config
  paginates_per 5

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
    content = content_type.constantize.find_or_initialize_by_id(content_id)
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

  def total_likes
    cached_votes_total
  end

  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM user_relationships WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids})", user_id: user.id)
  end

  def self.sorting (order_column, interval)
    order_column = Fun.column_names.include?(order_column) ? order_column : "created_at"
    interval = %w(week month year).include?(interval) ? interval: "year"
    where(created_at: Time.now - 1.send(interval) .. Time.now).order(order_column + " DESC")
  end

  def self.filter_by_type (types=[])
    def_types = %w(image post video)
    types = types.nil? ? def_types : types.select { |type| type if type.in? def_types }
    where(content_type: types)
  end

  def repost_by(reposter)
    if self.user == reposter
      "Can't repost own fun"
    else
      new_fun = self.dup
      new_fun.user = reposter
      new_fun.save
      self.increment! :repost_count
      "Succesfully reposted"
    end
  end

  private
  def set_author
    self.author_id = self.author_id.zero? ? self.user_id : self.author_id
  end

end