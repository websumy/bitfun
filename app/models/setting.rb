class Setting < ActiveRecord::Base
  attr_accessible :birthday, :fb_link, :info, :location, :sex, :site, :tw_link, :vk_link
  belongs_to :user

  validates :fb_link, :tw_link, :vk_link, :site, format: { with: URI::regexp(%w(http https)), allow_blank: true}

end
