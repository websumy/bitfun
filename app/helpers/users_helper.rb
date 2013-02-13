module UsersHelper
  def follow_button user
   content_tag :div, class: 'circle_follow_status' do
      if current_user.following? user
        link_to '', user_follow_path(user, current_user), method: :delete, class: 'unfollow', rel: 'tooltip', title: t('user.unfollow')
      else
        link_to '', user_follows_path(user), method: :post, class: 'follow', rel: 'tooltip', title: t('user.follow')
      end
    end if user_signed_in? && current_user != user
  end

  def show_avatar(user, type = :big)
    image_tag( user.avatar? ? user.avatar_url(:img, type) : "default-avatar-#{type}.jpg" )
  end

  def show_user_link
    link_to user_path(current_user), class: "item_link signUp" do
      raw "<div class='avatar_wrapper'>" +
            show_avatar(current_user, :small) +
          "</div><span class='span_cell'><span>#{current_user.login}</span></span>"
    end
  end

end