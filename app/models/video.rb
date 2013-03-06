class Video < ActiveRecord::Base
  require 'net/http'

  attr_accessible :title, :url, :remote_image_url, :tag_list
  mount_uploader :image, ImageUploader

  validate :check_video_url

  # Tags
  acts_as_taggable

  ALIASES = {
    youtube:  %w(youtube.com youtu.be),
    vimeo:    %w(vimeo.com)
  }

  has_many :fun, as: :content, dependent: :destroy

  def url= url
    url.strip!
    ALIASES.each { |k, v| v.each { |i| self.video_type = k if i.in? url } }
    if self.video_type.present?
      self.video_id = send "parse_#{self.video_type}", url
      self.remote_image_url = send "thumb_url_#{self.video_type}" if self.video_id.present?
    end
    super
  end

  def exist_gif_thumb?
    self.image.gif.file.exists?
  end

  private
  def check_video_url
    if self.video_type.present?
      errors.add(:url, 'cant find video from this url') unless self.video_id.present?
    else
      errors.add(:url, 'only Youtube.com, Vimeo.com links can be posted')
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

  def thumb_url_youtube
    url = "http://gdata.youtube.com/feeds/api/videos/#{self.video_id}?v=2"
    urls, keys  = {}, %w(sddefault hqdefault mqdefault default)
    response = Net::HTTP.get_response(URI.parse(url))
    result = Hash.from_xml(response.body)
    result['entry']['group']['thumbnail'].each { |item| urls[item['yt:name']] = item['url'] }
    keys.each { |key| return urls[key] if urls.has_key? key }
  end

  def thumb_url_vimeo
    url = "http://vimeo.com/api/v2/video/#{self.video_id}.xml"
    response = Net::HTTP.get_response(URI.parse(url))
    result = Hash.from_xml(response.body)
    result['videos']['video']['thumbnail_large']
  end

end