module UsersHelper
  def follow_button user
   content_tag :div, class: 'circle_follow_status' do
      if current_user == user
        link_to '', edit_user_registration_path, class: 'settings', rel: 'tooltip', title: t('user.settings')
      elsif current_user.following? user
        link_to '', delete_user_follows_path(user), method: :delete, class: 'unfollow', rel: 'tooltip', title: t('user.unfollow'), remote: true, data: { type: :json }
      else
        link_to '', user_follows_path(user), method: :post, class: 'follow', rel: 'tooltip', title: t('user.follow'), remote: true, data: { type: :json }
      end
    end if user_signed_in?
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