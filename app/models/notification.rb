class Notification < ActiveRecord::Base
  attr_accessible :target_id, :target_type,
                  :target, :action,
                  :user_id, :receiver_id

  belongs_to :target, polymorphic: true
  belongs_to :user

  validates_presence_of :target_id
  validates_presence_of :user_id
  validates_presence_of :action
end
