class Fun < ActiveRecord::Base
  attr_accessible :name, :string, :tag_list
  acts_as_taggable

  paginates_per 1
  attr_writer :tag_names

  # Associations
  belongs_to :user

  # Validation
  validates :user_id, :presence => true
  validates :name, :presence => true

  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM #{:user_relationships} WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids})", user_id: user.id)
  end

end