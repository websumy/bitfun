class Setting < ActiveRecord::Base
  extend Enumerize

  attr_accessible :birthday, :fb_link, :info, :location, :sex, :site, :tw_link, :vk_link
  belongs_to :user

  enumerize :sex, :in => { male: 1, female: 2 }

  validates :fb_link, :tw_link, :vk_link, :site, format: { with: URI::regexp(%w(http https)), allow_blank: true}

end
