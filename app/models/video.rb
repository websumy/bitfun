class Video < ActiveRecord::Base
  attr_accessible :video, :url, :tag_list

  validate :check_video_url

  # Tags
  acts_as_taggable

  ALIASES = {
    youtube:  %w(youtube.com youtu.be),
    vimeo:    %w(vimeo.com)
  }

  has_many :fun, :as => :content, :dependent => :destroy

  def url= url
    ALIASES.each { |k, v| v.each { |i| self.video_type = k if i.in? url } }
    self.video_id = send "parse_#{self.video_type}", url if self.video_type.present?
    super
  end

  private
  def check_video_url
    if self.video_type.present?
      errors.add(:url, "can't find video from this url") unless self.video_id.present?
    else
      errors.add(:url, "only Youtube.com, Vimeo.com links can be posted")
    end
  end

  def parse_youtube url
    regex = /^(?:http:\/\/)?(?:www\.)?\w*\.\w*\/(?:watch\?v=)?((?:p\/)?[\w\-]+)/
    matches = url.match(regex)
    matches[1] unless matches.nil?
  end

  def parse_vimeo url
    regex = /^(?:http:\/\/)?(?:www\.)?vimeo\.com\/(\d+)/
    matches = url.match(regex)
    matches[1] unless matches.nil?
  end

end