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


  private


end
