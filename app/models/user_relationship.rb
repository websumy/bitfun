class UserRelationship < ActiveRecord::Base
  attr_accessible :followed_id, :follower_id

  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates_presence_of :follower_id, :followed_id
  validates_uniqueness_of :follower_id, scope: :followed_id

  validate cant_follow_yourself

  def cant_follow_yourself
    errors.add(:follower_id, t('follows.cant_follow')) if follower_id == followed_id
  end

end