class UserRelationship < ActiveRecord::Base
  attr_accessible :followed_id, :follower_id

  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates :follower_id, :followed_id, presence: true
  validates :follower_id, uniqueness: { scope: :followed_id }

  validate :cant_follow_yourself

  def cant_follow_yourself
    errors.add(:follower_id, I18n.t('follows.cant_follow')) if follower_id == followed_id
  end

end