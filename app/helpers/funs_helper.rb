module FunsHelper

  def fun_path(fun)
    super fun.get_id
  end

  def render_fun_partial(fun, partial)
    render "funs/#{fun.content_type.downcase.pluralize}/#{partial}", fun: fun
  end

  def show_cached_tags(fun)
    fun.content.cached_tag_list.split(', ').map { |t| link_to t, tag_path(t) }.join(', ').html_safe
  end

  def repost_button(fun)
    link_to raw('Share ' + content_tag('span', fun.repost_counter, class: 'badge badge-info')), fun_reposts_path(fun.get_id), class: 'repost', 'data-type'.to_sym => 'json', 'data-method'.to_sym => 'post', remote: true
  end

  def like_button(fun)
    if current_user && current_user.voted_up_on?(fun)
      link_to raw(content_tag('span','Unlike fun ') + content_tag('span', fun.total_likes, class: 'badge badge-success')), delete_fun_likes_path(fun), class: 'like', 'data-type'.to_sym => 'json', method: :delete,  remote: true
    else
      link_to raw(content_tag('span','Like fun ') + content_tag('span', fun.total_likes, class: 'badge badge-info')), fun_likes_path(fun), class: 'like', 'data-type'.to_sym => 'json', method: :post, remote: true
    end
  end

  def active_class?(key, value)
    cookies = cookies_store[key]
    default_value = case key
                      when :type then %w(image post video)
                      when :interval then "year"
                      when :view then "list"
                      else ""
                    end

    if value.in? (cookies ? cookies : default_value)
      " active"
    end
  end

  def view_partial
    default = "list"
    partial = params[:view] ||= cookies_store[:view]
    ((partial.in? %w(list box)) ?  partial : default) + "_item"
  end

  def link_to_menu(name, options = {}, html_options = {})
    if html_options.key? :class
      html_options[:class] << " active" if current_page?(options)
    end

    link_to(name, options, html_options)
  end



end