class Comment < ActiveRecord::Base
  after_create :update_commentable_counter
  after_destroy :update_commentable_counter
  after_create :create_notification

  attr_accessible :commentable, :body, :user_id
  acts_as_nested_set scope: [:commentable_id, :commentable_type]

  ANSWER_DEPTH = 7

  validates :body, :user, presence: true

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  acts_as_votable

  belongs_to :commentable, polymorphic: true

  # NOTE: Comments belong to a user
  belongs_to :user

  has_many :notifications, as: :subject, dependent: :destroy

  # Helper class method to lookup all comments assigned
  # to all commentable types for a given user.
  scope :find_comments_by_user, lambda { |user|
    where(user_id: user.id).order('created_at DESC')
  }

  # Helper class method to look up all comments for
  # commentable class name and commentable id.
  scope :find_comments_for_commentable, lambda { |commentable_str, commentable_id|
    where(commentable_type: commentable_str.to_s, commentable_id: commentable_id).order('created_at DESC')
  }

  def allowed_to_answer?
    depth.to_i < ANSWER_DEPTH
  end

  class << self
    # Helper class method that allows you to build a comment
    # by passing a commentable object, a user_id, and comment text
    # example in readme
    def build_from(obj, user_id = nil, comment = '')
      new commentable: obj, body: comment, user_id: user_id
    end

    # Helper class method to look up a commentable object
    # given the commentable class name and id
    def find_commentable(commentable_str, commentable_id)
      commentable_str.constantize.find(commentable_id)
    end
  end

  private

  def update_commentable_counter
    commentable.update_comments_count if commentable.respond_to? :update_comments_count
  end

  def create_notification
    self.notifications.create(user_id: user_id, action: :create)
  end
end
