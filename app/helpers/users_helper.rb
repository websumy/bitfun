module UsersHelper
  def follow_button user
    content_tag :div, id: "follow_form" do
      if current_user.following? user
        link_to "Unfollow", user_follow_path(user, current_user), method: :delete, class: "btn"
      else
        link_to "Follow", user_follows_path(user), method: :post, class: "btn btn-primary"
      end
    end if user_signed_in? && current_user != user
  end

  def show_user_link
    link_to user_path(current_user), class: "item_link signUp" do
      raw "<div class='avatar_wrapper'>" +
            image_tag( current_user.avatar? ? current_user.avatar_url(:img, :small) : 'default-avatar-32.jpg' ) +
          "</div><span class='span_cell'><span>#{current_user.login}</span></span>"
    end
  end

end