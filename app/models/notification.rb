class Notification < ActiveRecord::Base
  attr_accessible :target_id, :target_type, :target,
                  :subject_id, :subject_type, :subject,
                  :action, :user_id, :receiver_id, :fun

  belongs_to :subject, polymorphic: true
  belongs_to :target, polymorphic: true
  belongs_to :user
  belongs_to :fun

  validates_presence_of :subject_id
  validates_presence_of :user_id
  validates_presence_of :action

  def group_param(key)
    case key
      when :subject then "#{subject_type}_#{subject_id}"
      when :user then user_id
      when :target  then target_id ? "#{target_type}_#{target_id}" :fun_id
      else nil
    end
  end
end
