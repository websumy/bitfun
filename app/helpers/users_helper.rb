module UsersHelper
  def follow_button user
    unless current_user == user
      content_tag :div, id: "follow_form" do
        if current_user.following? user
          form_tag unfollow_user_path, method: :delete do
            submit_tag "Unfollow", class: "btn"
          end
        else
          form_tag follow_user_path, method: :put do
            raw(
              hidden_field( :user_relationship, :followed_id, value: user.id ) +
              submit_tag("Follow", class: "btn btn-primary")
            )
          end
        end
      end
    end
  end

end
