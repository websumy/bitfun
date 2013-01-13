class Fun < ActiveRecord::Base
  attr_accessible :title, :content_attributes, :content_type

  # Kaminari pagination config
  paginates_per 5

  # Fun moved from sandbox when total_likes = MIN_LIKES
  MIN_LIKES = 1

  # Associations
  belongs_to :user
  belongs_to :content, :polymorphic => true, :dependent => :destroy
  accepts_nested_attributes_for :content, :allow_destroy => true

  # Reposts
  has_many :reposts

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

  # Do repost fun
  def repost_by(reposter)
    if self.user != reposter
      fun = self.dup
      fun.update_attributes({user: reposter, author_id: reposter.id, cached_votes_total: 0, repost_count: 0}, without_protection: true)
      self.increment! :repost_count
      self.reposts.create(user_id: reposter.id)
      fun
    end
  end

  # Like fun, return type
  def like_by(user)
    if user.voted_up_on? self
      self.unliked_by voter: user
      "unlike"
    else
      self.liked_by user
      # Update created_at, when fun moved from sandbox. Or maybe overwrite method ActsAsVotable::Votable update_cached_votes?
      self.update_attribute :created_at, Time.now if total_likes == MIN_LIKES
      "like"
    end
  end

  class << self

    def from_users_followed_by(user)
      followed_user_ids = "SELECT followed_id FROM user_relationships WHERE follower_id = :user_id"
      where("user_id IN (#{followed_user_ids})", user_id: user.id)
    end

    # Sorting funs by allowed fields including interval and sandbox options
    def sorting(order_column, options)
      interval = options[:interval]
      sandbox = options[:sandbox]
      order_column = Fun.column_names.include?(order_column) ? order_column : "created_at"
      interval = %w(week month year).include?(interval) ? interval: "year"
      scope = scoped
      scope = where(created_at: Time.now - 1.send(interval) .. Time.now).where("cached_votes_total >= ?", MIN_LIKES) unless sandbox
      scope.order(order_column + " DESC")
    end

    def clean_types(types=[])
      def_types = %w(image post video)
      if types.nil?
        def_types
      else
        types = [types].flatten
        types.first == "unknown" ? nil:  types.select { |type| type.in? def_types }
      end
    end

    # Filter fun by type
    def filter_by_type(types=[])
      where(content_type: clean_types(types))
    end

    # Find tags for autocomplete
    def find_tags_by_name(tag)
      ActsAsTaggableOn::Tag.includes(:taggings).where("taggings.context = 'tags'").order("name ASC").named_like(tag).limit(10) unless tag.blank?
    end

    # Content types for searching
    def search_fun_ids(query, types=[], p)
      content_type = { image: 1, video: 2, post: 3 }
      query = [query].flatten.join(',')
      types = clean_types types
      types.map!{ |t|t.to_sym }
      types = content_type.select{| k| k.in? types }.values
      Fun.search_for_ids(query, with: {type: types}, :match_mode => :any).page(p).per(default_per_page)
    end

  end

  # Thinking Sphinx index
  define_index do
    indexes title, sortable: true
    indexes content.cached_tag_list, :as => :tags

    has '(CASE WHEN content_type = "Image" THEN 1 WHEN content_type = "Video" THEN 2 WHEN content_type = "Post" THEN 3 END)', :as => :type, :type => :integer
  end
end