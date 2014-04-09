class Fun < ActiveRecord::Base
  attr_accessible :content_attributes, :content_type, :comments_count
  attr_accessible :content_id, :content_type, :user_id, :owner_id, as: :admin
  after_destroy :delete_content
  before_destroy :delete_likes
  before_destroy :delete_reposts

  # Kaminari pagination config
  paginates_per 10

  # Fun moved from sandbox when total_likes = MIN_LIKES
  MIN_LIKES = 3

  # Default types of Funs
  DEF_TYPES = %w(image video post)

  # Associations
  belongs_to :user
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'
  belongs_to :content, polymorphic: true
  accepts_nested_attributes_for :content, allow_destroy: true
  has_many :reports, dependent: :destroy

  # Reposts
  has_many :reposts, class_name: 'Fun', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'Fun'

  # Initialize "acts_as_votable" gem for "likes"
  acts_as_votable

  def attributes=(attributes = {})
    self.content_type = attributes[:content_type]
    super
  end

  def build_content(params, assignment_options)
    raise "Unknown content_type: #{content_type}" unless DEF_TYPES.include?(content_type.downcase)
    params[:url] = params[:remote_file_url] if content_type == 'Image'
    self.content = content_type.constantize.new(params)
  end

  # Validation
  validates :user_id, presence: true

  # Can do only one repost for one fun
  validates :parent_id, uniqueness: { scope: :user_id, message: I18n.t('reposts.errors.already_reposted'), unless: lambda { |i| i.parent_id.nil? } }
  # Can't repost own funs
  validate :cant_repost_own_fun

  # Scopes
  default_scope where('parent_id IS NULL')
  scope :images, where(content_type: 'Image')
  scope :videos, where(content_type: 'Video')
  scope :posts, where(content_type: 'Post')
  scope :published, lambda { |show = true| where("published_at IS #{show ? 'NOT':''} NULL") }
  # Filter fun by type
  scope :filter_by_type, lambda { |types| where(content_type: clean_types(types)) }
  scope :exclude_funs, lambda { |ids| where('id NOT IN (?)', ids) }

  def repost?
    !parent_id.nil?
  end

  def get_reposts
    Fun.unscoped.where(parent_id: id)
  end

  def get_id
    repost? ? parent_id : id
  end

  def total_likes
    cached_votes_total
  end

  def create_repost(reposter)
    fun = reposts.create!({ user_id: reposter.id, owner_id: user.id, content_id: content_id, content_type: content_type }, as: :admin)
    increment! :repost_counter
    fun
  end

  # Do repost fun
  def repost_by(reposter)
    if repost?
      fun = parent.create_repost reposter
      increment! :repost_counter
      fun
    else
      create_repost reposter
    end
  end

  # Update published_at, when fun moved from sandbox. Or maybe overwrite method ActsAsVotable::Votable update_cached_votes?
  def update_published_at
    update_attribute :published_at, Time.now if total_likes == MIN_LIKES
  end

  # Like fun
  def like_by(user)
      liked_by user
      parent.liked_by user if repost?
      update_published_at
  end

  # Unlike fun
  def unlike_by(user)
    unliked_by voter: user
    parent.unliked_by voter: user if repost?
    update_published_at
  end

  def in_sandbox?
    !published_at.nil?
  end

  # get related funs without funs liked by user
  def get_related(user, type)
    exclude = [id]
    exclude.concat user.get_voted_ids(month_range(3)) unless user.blank?
    related_ids = Fun.search_fun_ids(content.cached_tag_list, type)
    Fun.where(id: related_ids).exclude_funs(exclude).where(published_at: month_range(3)).filter_by_type(type).order('cached_votes_total DESC').limit 3
  end

  # get max liked funs of the month without funs liked by user
  def get_month_trends(user, type)
    exclude = [id]
    exclude.concat user.get_voted_ids(month_range) unless user.blank?
    Fun.exclude_funs(exclude).where(published_at: month_range).filter_by_type(type).order('cached_votes_total DESC')
  end

  class << self

    def reposters
      includes(:user).map(&:user)
    end

    def from_users_followed_by(user)
      followed_user_ids = "SELECT followed_id FROM user_relationships WHERE follower_id = :user_id"
      where("user_id IN (#{followed_user_ids})", user_id: user.id)
    end

    def order_by(order_column)
      order_column = Fun.column_names.include?(order_column) ? order_column : 'published_at'
      order(order_column + ' DESC')
    end

    def interval(interval, sandbox = false)
      interval = %w(day week month year).include?(interval) ? interval: "year"
      where(sandbox ? :created_at : :published_at => 1.send(interval).ago .. Time.now)
    end

    # Sorting funs by allowed fields including interval and sandbox options
    def sorting(order_column, options)
      sandbox = options[:sandbox]
      published(sandbox.nil?).interval(options[:interval], sandbox).order_by(order_column)
    end

    def clean_types(types=[])
      if types.nil?
        DEF_TYPES
      else
        types = [types].flatten
        types.first == 'unknown' ? nil:  types.select { |type| type.in? DEF_TYPES }
      end
    end

    # Find tags for autocomplete
    def find_tags_by_name(tag)
      ActsAsTaggableOn::Tag.includes(:taggings).where("taggings.context = 'tags'").order("name ASC").named_like(tag).limit(10) unless tag.blank?
    end

    # Content types for searching
    def search_fun_ids(query, types=[])
      query = query.split(',').reject(&:blank?).map(&:strip).join('|')
      types = clean_types types
      type_index = []
      unless types.nil?
        DEF_TYPES.each{|t| type_index << DEF_TYPES.index(t) if t.in? types }
        Fun.search_for_ids(query, with: {type: type_index}, max_matches: 100, per_page: 100)
      end
    end

    def create_tag_cloud(type)
      type = clean_types type
      tags = []
      if type.is_a? Array
        type.each do |t|
          tags.concat t.capitalize.constantize.tag_counts_on(:tags)
        end
      elsif type != 'unknown'
        tags = type.capitalize.constantize.tag_counts_on(:tags)
      end
      tags.uniq.shuffle
    end

  end

  def month_range(month = 1)
    month.month.ago .. Time.now
  end

  def cant_repost_own_fun
    errors.add(:user_id, I18n.t('reposts.errors.cant_repost_own')) if user_id == owner_id
  end

  def delete_likes
    likes.delete_all
  end

  def delete_reposts
    if repost?
      parent.decrement! :repost_counter
    else
      get_reposts.destroy_all
    end
  end
  def delete_content
    content.destroy unless repost?
  end
end