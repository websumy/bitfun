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
      when :user then "#{user_id}_#{subject_type}_#{target_type}"
      when :target then group_target_key
      else nil
    end
  end

  def group_target_key
    sub = target_id ? "#{target_type}_#{target_id}" : fun_id
    "#{subject_type}_#{sub}"
  end

  def msg_key(prefix = true)
    [].tap do |parts|
      parts.push(:notification) if prefix
      parts << normalize_key(subject_type)
      parts << (target_id ? normalize_key(target_type) : :fun)
    end.join('.')
  end

  def normalize_key(key)
    key.downcase.gsub(/[^a-z]/, '')
  end
end
