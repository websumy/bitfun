module UsersHelper
  def link_to_follow(content, user, html_options)
    status = current_user.following?(user)
    options = { method: :post, rel: 'tooltip', title: t('user.follow'), remote: true, data: { type: :json }, style: "display: #{status ? 'none' : 'inline-block'};" }
    link_to(content, user_follows_path(user), options.merge(html_options))
  end

  def link_to_unfollow(content, user, html_options)
    status = current_user.following?(user)
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
    link_to user_path(current_user), class: "item_link signUp" do
      raw "<div class='avatar_wrapper'>" +
            show_avatar(current_user, :small) +
          "</div><span class='span_cell'><span>#{current_user.login}</span></span>"
    end
  end

end