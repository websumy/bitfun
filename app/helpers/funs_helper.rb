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
    link_to raw('Share ' + content_tag('span', fun.repost_counter, class: 'badge badge-info')), fun_reposts_path(fun), class: 'repost', 'data-type'.to_sym => 'json', method: 'post', remote: true
  end

  def like_button(fun)
    if current_user && current_user.voted_up_on?(fun)
      content_tag 'div', class: 'item_wrapper like_box first_item active' do
        link_to "<span class='icon'></span><span class='counter'>#{fun.total_likes}</span>".html_safe, delete_fun_likes_path(fun), class: 'item', data: { type: :json }, method: :delete,  remote: true
      end
    else
      content_tag 'div', class: 'item_wrapper like_box first_item' do
        link_to "<span class='icon'></span><span class='counter'>#{fun.total_likes}</span>".html_safe, fun_likes_path(fun), class: 'item', data: { type: :json }, method: :post, remote: true
      end
    end
  end

  def active_class?(key, value)
    default = case key
                when :type then %w(image post video)
                when :interval then "year"
                when :view then "list"
                else ""
              end
    data = cookies_store[key] ? cookies_store[key] : default
    value.in?(data) ? ' active' : ''
  end

  def selected_option?(value)
    active_class?(:interval, value).length > 0 ? 'selected=\'selected\'' : ''
  end

  def select_options
    %w(year month week day).collect { |key| "<option value='#{key}' #{selected_option?(key)}>" + t("select_options." + key) + '</option>' }.join.html_safe
  end

  def link_to_type(type)
    content_tag :span do
      link_to '', '/', class: type + active_class?(:type, type),  data: { value: type}
    end
  end

  def view_partial
    default = "list"
    partial = params[:view] ||= cookies_store[:view]
    ((partial.in? %w(list box)) ?  partial : default) + "_item"
  end

  def link_to_menu(name, options = {}, html_options = {})
    current_class  = current_page?(options) ? " active" : ""
    raw "<div class='item_wrapper#{current_class}'><div class='item'>" +
      link_to(name, options, html_options) +
    '</div><span></span></div>'
  end


  def user_block(user, content_type)
    raw '<div class="photo_frame">' +
        link_to(show_avatar(user, :main), user, class: 'photo_box') +
        '<div class="arrow"></div>' +
        follow_button(user).to_s +
        "<div class='circle_content_obj'><div class='#{content_type}'></div></div></div>"
  end

end