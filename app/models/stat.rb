class Stat < ActiveRecord::Base
  belongs_to :user
  attr_accessible :user, :user_id,
                  :day_votes, :week_votes, :month_votes, :all_votes,
                  :day_funs, :week_funs, :month_funs, :all_funs,
                  :day_reposts, :week_reposts, :month_reposts, :all_reposts,
                  :day_followers, :week_followers, :month_followers, :all_followers,

  # after_filters increment necessary fields. but every days update all field by cron only that users who need it

  class << self

    def recount(user, type)
      result, type  = {}, type.to_s
      if type.in?(%w(votes funs reposts followers)) and user.present?
        %w(day week month all).each { |period|
          result[:"#{period}_#{type}"] = user.send('count_' + type, period != 'all' ? 1.send(period).ago .. Time.now : nil) }
        Stat.find_or_create_by_user_id(user_id: user.id).update_attributes result
      end
    end

  end
end