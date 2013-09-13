class Report < ActiveRecord::Base
  belongs_to :fun
  belongs_to :user

  attr_accessible :abuse, :user
  validates :abuse, presence: true
  validates :user_id, uniqueness: { scope: :fun_id }

end
