class Repost < ActiveRecord::Base
  attr_accessible :fun_id, :user_id

  belongs_to :fun
  belongs_to :user

  def self.reposters
    includes(:user).map(&:user)
  end

  validates_presence_of :fun_id
  validates_presence_of :user_id
end
