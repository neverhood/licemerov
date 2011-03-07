module FriendshipsHelper

  def show(options = {:inactive => false})
    html_class = (options[:inactive] == true) ? :inactive : nil
    link_to t(:friends), friends_path(current_user), :id => 'friends', :class => html_class
  end

  def show_pending(html_class)
    pending_friends_count = User.pending_friends_of(current_user).count
    if pending_friends_count > 0
      link_to friends_path(current_user, :section => 'pending'),
              :class => html_class, :id => 'pending-friends' do
        "<span>#{t(:pending_friends)}(<strong>#{pending_friends_count.to_s}</strong>)</span>".html_safe
      end
    else
      nil
    end
  end

  def show_online(options = {:inactive => true})
    html_class = (options[:inactive] === true) ? :inactive : nil
    link_to t(:friends_online), friends_path(current_user, :section => 'online'), :class => html_class
  end

  def show_blacklist(options = {:inactive => true})
    html_class = (options[:inactive] == true) ? :inactive : nil
    link_to t(:blacklist), friends_path(current_user, :section => 'blacklist'), :class => html_class
  end

  def destroy(friendship)
    login = User.where(:id => (friendship.user_id == current_user.id)?
        friendship.friend_id : friendship.user_id).first.login
    link_to t(:delete_friend), friendship, :method => :delete, :remote => true,
            :id => 'delete-friend', :confirm => t(:confirm_friend_delete, :name => login)
  end

  def add
     link_to t(:add_friend), friendships_path(:friend_id => @user.id), :remote => true, :method => :post,
                    :id => 'add-friend' 
  end

end
