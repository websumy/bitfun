class Setting < ActiveRecord::Base
  attr_accessible :birthday, :fb_link, :info, :location, :sex, :site, :tw_link, :vk_link
  belongs_to :user
end
