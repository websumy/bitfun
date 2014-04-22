module ActsAsVotable
  class Vote < ActiveRecord::Base

    after_create :create_notification
    has_many :notifications, as: :subject, dependent: :destroy

    private

    def create_notification
      return if voter_id == votable.user_id

      data = { user_id: voter_id, action: :create, receiver_id: votable.user_id }
      data[:fun] = votable.notification_fun if votable.respond_to? :notification_fun
      data[:target] = votable unless data[:fun] || data[:fun] == votable

      notifications.create(data)
    end
  end
end