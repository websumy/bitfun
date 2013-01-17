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
end