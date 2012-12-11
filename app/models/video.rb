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

  def attributes=(attributes = {})
    ALIASES.each do |method, links|
      links.each do |link|
        if attributes[:url].include? link
          self.video_type = method
          break
        end
      end
    end

    self.video_id = send "parse_#{self.video_type}".to_sym, attributes[:url] if self.video_type.present?
    super
  end

  private

  def check_video_url
    type = nil
    ALIASES.each do |method, links|
      links.each do |link|
        if self.url.include? link
          type = method
          break
        end
      end
    end

    if type.present?
      errors.add(:url, "can't find video from this url") if send("parse_#{type}".to_sym, self.url).nil?
    else
      errors.add(:url, "only Youtube.com, Vimeo.com links can be posted")
    end

  end

  def parse_youtube url
    url.strip!
    regex = /^(?:http:\/\/)?(?:www\.)?\w*\.\w*\/(?:watch\?v=)?((?:p\/)?[\w\-]+)/
    url.match(regex)[1] unless url.match(regex).nil?
  end

  def parse_vimeo url
    url.strip!
    regex = /^(?:http:\/\/)?(?:www\.)?vimeo\.com\/(\d+)/
    url.match(regex)[1] unless url.match(regex).nil?
  end

end