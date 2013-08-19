module UsersHelper
  def link_to_follow(content, user, html_options)
    status = current_user.follow?(user)
    options = { method: :post, rel: 'tooltip', title: t('user.follow'), remote: true, data: { type: :json }, style: "display: #{status ? 'none' : 'inline-block'};" }
    link_to(content, user_follows_path(user), options.merge(html_options))
  end

  def link_to_unfollow(content, user, html_options)
    status = current_user.follow?(user)
    options = { method: :delete, rel: 'tooltip', title: t('user.unfollow'), remote: true, data: {type: :json}, style: "display: #{status ? 'inline-block' : 'none'};" }
    link_to(content, delete_user_follows_path(user), options.merge(html_options))
  end

  def follow_button user
   content_tag :div, class: 'circle_follow_status follow_parent' do
      if current_user == user
        link_to '', edit_user_registration_path, class: 'settings', rel: 'tooltip', title: t('user.settings'), style: 'display:inline-block'
      else
        link_to_follow('', user, { class: 'follow' }) +
        link_to_unfollow('', user, { class: 'unfollow' })
      end
    end if user_signed_in?
  end

  def follow_link user
    if user_signed_in? && current_user != user
      link_to_follow(raw('<i class="icon"></i>') + t('user.follow'), user, { class: 'btn-follow' }) +
      link_to_unfollow(raw('<i class="icon"></i>') + t('user.unfollow'), user, { class: 'btn-follow active' })
    end
  end

  def follow_link_rating user
    if user_signed_in? && current_user != user
      link_to_follow('', user, { class: 'btn-follow follow' }) +
      link_to_unfollow('', user, { class: 'btn-follow unfollow' })
    end
  end

  def show_avatar(user, type = nil)
    image_tag( user.avatar_url :img, type )
  end

  def show_user_link
    link_to user_path(current_user), class: "item_link signUp", rel: 'tooltip', title: t('funs.titles.myprofile') do
      raw "<div class='avatar_wrapper'>" +
            show_avatar(current_user, :small) +
          "</div><span class='span_cell'><span>#{current_user.login}</span></span>"
    end
  end

  def sort_to(column)
    direction = (sort_column == column && sort_direction == 'desc') ? 'asc' : 'desc'
    link_to(raw(t("user.sort.#{column}") + '<i class="icon"></i>'), { sort: column, direction: direction, interval: sort_interval }, rel: 'tooltip', title: t('funs.titles.sort.' + column), class: sort_column == column ? direction : nil)
  end

  def active?(column)
    sort_column == column ? 'active' : ''
  end

  def next_users_url(users)
    current_state = { sort: sort_column, direction: sort_direction, interval: sort_interval }
    content_tag(:div, id: 'current_users_url', data: { url: url_for(current_state.merge({ page: users.current_page + 1 })), current: url_for(current_state) }){}
  end

  def list_title
    l = if params[:controller] == 'users/follows'
          if params[:type] == 'followers'
            'followers'
          else
            'following'
          end
        else
          'rating'
        end
    user = params[:id] ? ' ' + params[:id] : ''
    t('user.list.' + l) + user
  end

  def omniauth_link(resource, provider)
    if current_user.binded? provider
      link_to '', unbind_identity_path(provider), class: 'unbind'
    else
      link_to '', omniauth_authorize_path(resource, provider)
    end
  end

end