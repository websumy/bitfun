class Repost < ActiveRecord::Base
  attr_accessible :fun_id, :user_id

  belongs_to :fun
  belongs_to :user

  validates_presence_of :fun_id
  validates_presence_of :user_id
end
