class Repost < ActiveRecord::Base
  attr_accessible :fun_id, :user_id, :owner_id
  attr_accessor :owner_id

  belongs_to :fun
  belongs_to :user

  validates :fun_id, :user_id, presence: true
  validates :fun_id, uniqueness: { scope: :user_id }

  validate :cant_repost_own_funs

  def cant_repost_own_funs
    errors.add(:user_id, I18n.t('reposts.errors.cant_repost_own')) if user_id == owner_id
  end

  def self.reposters
    includes(:user).map(&:user)
  end
end