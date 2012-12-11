class Video < ActiveRecord::Base
  attr_accessible :video, :url, :video_id, :tag_list

  # Tags
  acts_as_taggable

  before_save :set_video_type_id,

  has_many :fun, :as => :content, :dependent => :destroy


  private
  def set_video_type_id

    aliases = {
        vk:       %w(vkontakte.ru vk.com),
        youtube:  %w(youtube.com, youtu.be),
        vimeo:    %w(vimeo.com)
    }

    aliases.each do |method, links|
      links.each do |link|
        self.video_type = method if self.url.include? link
      end
    end

    self.video_id = send("parse_#{self.video_type}".to_sym, self.url) if self.video_type.present?


  end

  def parse_youtube url
    regex = /^(?:http:\/\/)?(?:www\.)?\w*\.\w*\/(?:watch\?v=)?((?:p\/)?[\w\-]+)/
    url.match(regex)[1]
  end

  def parse_vimeo url
    regex = /^(?:http:\/\/)?(?:www\.)?vimeo\.com\/(\d+)/
    url.match(regex)[1]
  end

  def parse_vkontakte url
    regex = /^(?:http:\/\/)?(?:www\.)?vimeo\.com\/(\d+)/
    url.match(regex)[1]
  end

end