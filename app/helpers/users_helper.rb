module UsersHelper
  def follow_button user
   content_tag :div, class: 'circle_follow_status follow_parent' do
      if current_user == user
        link_to '', edit_user_registration_path, class: 'settings', rel: 'tooltip', title: t('user.settings'), style: 'display:inline-block'
      else
        status = current_user.following?(user)
        link_to('', delete_user_follows_path(user), method: :delete, class: 'unfollow', rel: 'tooltip', title: t('user.unfollow'), remote: true, data: { type: :json }, style: "display: #{status ? 'inline-block' : 'none'};") +
        link_to('', user_follows_path(user), method: :post, class: 'follow', rel: 'tooltip', title: t('user.follow'), remote: true, data: { type: :json }, style: "display: #{status ? 'none' : 'inline-block'};")
      end
    end if user_signed_in?
  end

  def follow_link user
    if user_signed_in? && current_user != user
      status = current_user.following?(user)
        link_to(raw('<i class="icon"></i>') + t('user.unfollow'), delete_user_follows_path(user), method: :delete, class: 'btn-follow active', remote: true, data: { type: :json }, style: "display: #{status ? 'inline-block' : 'none'};") +
        link_to(raw('<i class="icon"></i>') + t('user.follow'), user_follows_path(user), method: :post, class: 'btn-follow', remote: true, data: { type: :json }, style: "display: #{status ? 'none' : 'inline-block'};")
    end
  end

  def follow_link_rating user
    if user_signed_in? && current_user != user
      status = current_user.following?(user)
      link_to('', delete_user_follows_path(user), method: :delete, class: 'btn-follow unfollow', remote: true, data: { type: :json }, rel: 'tooltip', title: t('user.unfollow'), style: "display: #{status ? 'inline-block' : 'none'};") +
      link_to('', user_follows_path(user), method: :post, class: 'btn-follow follow', remote: true, data: { type: :json }, rel: 'tooltip', title: t('user.follow'), style: "display: #{status ? 'none' : 'inline-block'};")
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