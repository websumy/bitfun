module ActsAsVotable
  class Vote < ActiveRecord::Base

    after_create :create_notification
    has_many :notifications, as: :subject, dependent: :destroy

    private

    def create_notification
      notifications.create(user_id: voter_id, action: :create,
                           receiver_id: votable.user_id, target: votable)
    end

  end

end