module FunsHelper

  def fun_path(fun)
    super fun.get_id
  end

  def render_fun_partial(fun, partial)
    render "funs/#{fun.content_type.downcase.pluralize}/#{partial}", fun: fun
  end

  def show_cached_tags(fun)
    fun.content.cached_tag_list.split(', ').map { |t| link_to t, search_tags_path(query: t) }.join(', ').html_safe
  end

  def small_repost_button(fun)
    show_repost_button(fun, "<span class='icon'></span><span class='counter'><span class='slice rcnt'>#{fun.repost_counter}</span></span>")
  end

  def big_repost_button(fun)
    show_repost_button(fun, "<span class='icon'></span><span class='name'>#{t('reposts.button')}</span>") +
    "<div class='item_adds'><div class='navbar'><span class='counter rcnt'>#{fun.repost_counter}</span> #{t('reposts.count')}</div></div>".html_safe
  end

  def repost_button(fun)
    show_repost_button(fun, "<span class='icon'></span><span class='counter rcnt'>#{fun.repost_counter}</span>")
  end

  def small_like_button(fun)
    show_like_button fun, "<span class='icon'></span><span class='counter'><span class='slice lcnt'>#{fun.total_likes}</span></span>"
  end

  def like_button(fun)
    show_like_button fun, "<span class='icon'></span><span class='counter lcnt'>#{fun.total_likes}</span>"
  end

  def big_like_button(fun)
    show_like_button(fun, "<span class='icon'></span><span class='name'>#{t('likes.button')}</span>") +
        "<div class='item_adds'><div class='navbar'><span class='counter lcnt'>#{fun.total_likes}</span> #{t('likes.count')}</div></div>".html_safe
  end

  def wrapped_link_to(span, url = {}, html_options = {})
    options = { class: 'item', data: { type: :json } }
    options.merge! html_options
    wrapper_class = options[:wrapper_class]
    options.delete(:wrapper_class)
    content_tag 'div', class: 'item_wrapper ' + wrapper_class do
      link_to(span, url, options)
    end
  end

  def show_repost_button(fun, span)
    span = span.html_safe
    if user_signed_in?
      if current_user.reposted?(fun)
        wrapped_link_to span, fun_reposts_path(fun), data: { disabled: true }, wrapper_class: 'repost_box active'
      elsif current_user == fun.user
        wrapped_link_to span, fun_reposts_path(fun), data: { disabled: true }, wrapper_class: 'repost_box'
      else
        wrapped_link_to span, fun_reposts_path(fun), method: :post, remote: true, wrapper_class: 'repost_box'
      end
    else
      wrapped_link_to span, fun_reposts_path(fun), data: { auth: true }, wrapper_class: 'repost_box'
    end
  end

  def show_like_button(fun, span)
    span = span.html_safe
    if user_signed_in?
      if current_user.voted?(fun)
        wrapped_link_to span, delete_fun_likes_path(fun), method: :delete, remote: true, wrapper_class: 'like_box first_item active'
      else
        wrapped_link_to span, fun_likes_path(fun), method: :post, remote: true, wrapper_class: 'like_box first_item'
      end
    else
      wrapped_link_to span, fun_likes_path(fun), data: { auth: true }, wrapper_class: 'like_box first_item'
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
    partial = params[:view] ||= cookies_store[:view]
    (partial.in? %w(list box)) ?  partial : 'list'
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
        "<div class='circle_content_obj'><div class='#{content_type.downcase}'></div></div></div>"
  end

  def next_url(funs)
    params[:page] = funs.current_page + 1
    content_tag(:div, id: 'next_url', data: { url: url_for(params)}){}
  end

  def fun_add_line(fun, link = false)
    if fun.repost?
      raw content_tag(:span, '', class: 'repost', rel: 'tooltip', title: t('funs.reposted', reposter: fun.user.login, owner: fun.owner.login)) + (link ? link_to(fun.owner.login, fun.owner) : '')
    end
  end

  def remove_fun_link(fun)
    if can? :destroy, fun
      link_to '', url_for(action: 'show', controller: 'funs', id: fun), class: 'btn-fun-delete', method: :delete, remote: true, data: { type: :json }, confirm: t('funs.confirm.delete')
    end
  end

  def fun_image_path(fun, versions = {})
    type = fun.content.class.to_s
    column = type == 'Image' ? :file : :image # fun.content.class.uploaders
    unless type == 'Post'
      fun.content.try(column).url(*versions)
    else
      asset_path('social_logo.png')
    end
  end

  def fun_image_url(fun, versions = {})
    'http://' + request.host + fun_image_path(fun, versions).to_s
  end

  def fun_image(fun, options = {})
    versions = options[:version]
    options.delete(:version)
    text = fun.content.title? ? fun.content.title : fun.content.cached_tag_list
    options[:alt] = text unless options[:alt]
    options[:title] = text unless options[:title]
    image_tag(fun_image_path(fun, versions), options)
  end

  def fun_meta(fun)
    fun_keywords fun
    object = {
        og: {
            title: fun.content.title? ? fun.content.title : t('meta_tags.main.title'),
            site_name: t('meta_tags.main.title'),
            type: 'website',
            url: fun_url(fun),
            image: fun_image_url(fun, :small)
        },
        vk: {
            app_id: Settings.widgets.vkontakte.comments.id
        },
        fb: {
            app_id: Settings.oauth.facebook.id,
            admins: Settings.oauth.facebook.admins
        }
    }

    set_meta_tags object
  end

  def fun_keywords(fun)
    keywords fun.content.cached_tag_list + ', ' + t("meta_tags.fun.#{fun.content_type.downcase}.keywords") if fun.content.cached_tag_list?
  end

end