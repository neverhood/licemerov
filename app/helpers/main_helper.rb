module MainHelper

  def reply_button
    <<BUTTON
        <div>
          <strong class="reply">Reply</strong>
          <div class="form-placeholder"></div>
        </div>
BUTTON
  end

  def author(entry)
    <<AUTHOR
  <strong class="author-#{entry.author_gender}">
    #{link_to entry.login, user_profile_path(:user_profile => entry.login)}
  </strong>
AUTHOR
  end



end
