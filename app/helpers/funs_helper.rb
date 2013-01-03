module FunsHelper

  def render_fun_partial(fun, partial)
    render "funs/#{fun.content_type.downcase.pluralize}/#{partial}", fun: fun
  end

  def show_cached_tags(fun)
    fun.content.cached_tag_list.split(", ").map { |t| link_to t, tag_path(t) }.join(', ').html_safe
  end
end