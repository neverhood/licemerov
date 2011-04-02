module MessagesHelper

  def incoming(options = {:inactive => false})
    html_class = (options[:inactive] == true) ? :inactive : nil
    link_to t(:incoming_messages), user_messages_path(current_user), :class => html_class
  end

  def sent(options = {:inactive => false})
    html_class = (options[:inactive] == true) ? :inactive : nil
    link_to t(:sent_messages), user_messages_path(current_user, :section => 'sent'), :class => html_class
  end

  def new(options = {:inactive => false})
    html_class = (options[:inactive] == true) ? :inactive : nil
    link_to t(:new_message), new_message_path(current_user), :class => html_class
  end

  def links_box(current)
    [:incoming, :sent, :new].map {|method|  self.send(method, :inactive => (current == method.to_s))  }.
        join(' ').html_safe
  end

  def recover_message(message)
     link_to t(:cancel), cancel_deletion_message_path(message), :method => :post, :remote => true
  end

  def delete_message(message)
     link_to t(:delete_message), message, :method => :delete, :remote => true
  end

  def update_messages(action)
    link_to t(action), update_messages_path(:update => action),
            :method => :put, :remote => true, :class => "message-#{action}"
  end


  private


end
