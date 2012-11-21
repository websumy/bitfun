module FunsHelper
  def show_tags_links(tags = [], separator = ", ")
    tags.map{ |tag|
      link_to tag, funs_by_tag_path(tag)
    }.join(separator).html_safe
  end
end