module Funs::VideosHelper

  def show_video video, width = 560, height = 315
    src = {
      youtube:  "http://www.youtube.com/embed",
      vimeo:    "http://player.vimeo.com/video",
    }

    "<iframe width=\"#{width}\" height=\"#{height}\" src=\"#{src[video.video_type.to_sym]}/#{video.video_id}\" frameborder=\"0\" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>".html_safe
  end
end