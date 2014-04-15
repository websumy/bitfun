class Notification < ActiveRecord::Base
  attr_accessible :target_id, :target_type, :target,
                  :subject_id, :subject_type, :subject,
                  :action, :user_id, :receiver_id

  belongs_to :subject, polymorphic: true
  belongs_to :target, polymorphic: true
  belongs_to :user

  validates_presence_of :subject_id
  validates_presence_of :user_id
  validates_presence_of :action
end
