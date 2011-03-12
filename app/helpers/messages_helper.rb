module MessagesHelper

  def incoming(options = {:inactive => false})
    html_class = (options[:inactive] == true) ? :inactive : nil
    link_to t(:incoming_messages), messages_path(current_user), :class => html_class
  end

  def sent(options = {:inactive => false})
    html_class = (options[:inactive] == true) ? :inactive : nil
    link_to t(:sent_messages), messages_path(current_user, :section => 'sent'), :class => html_class
  end

end
