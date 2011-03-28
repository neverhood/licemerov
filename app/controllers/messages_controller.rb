class MessagesController < ApplicationController

  SECTIONS = ['sent']

  before_filter :require_owner, :only => :show
  before_filter :require_user, :only => :new
  before_filter :valid_section, :only => :show
  before_filter :valid_message, :only => [:update, :destroy]
  skip_before_filter :existent_user, :only => [:new, :create, :update, :destroy]


  # User to autocomplete users login when sending a new message
  #

  def new
      term = params[:term] # todo: validate 
      users = User.friends_of(current_user).where(['users.login LIKE ?', "%#{term}%"])
      render :json => users.map { |u|
        {
            :value => u.login,
            :id => u.id,
            :name => u.name,
            :avatar => u.avatar.url(:thumb)
        }
      }
  end

  def show
    @message = Message.new
    @messages = case params[:section]
                  when 'inbox' then current_user.incoming_messages
                  when 'sent' then current_user.messages
                end
  end

  def create
    @recipients = params[:message][:recipients].split(',').
      find_all { |id| id =~ /^\d+$/ }
    @recipients = [] unless (1..15).include? @recipients.size

    @messages = @recipients.map { |recipient|
      current_user.messages.build( :body => params[:message][:body],
                                   :subject => params[:message][:subject],
                                   :receiver_id => recipient.to_i )
    }

    @success = true

    @messages.each do |message|
      @success = false unless message.save
    end
    logger.info @messages.first.errors

    respond_to do |format|
      if @success
        format.js { render :json => {:message => t(:message_created), :html_class => :notice } }
        format.html { redirect_to :back, :notice => t(:message_created) }
      else
        render guilty_response
      end
    end
  end

  def destroy

  end

  def update  # Used to mark message(s) as deleted
  end

  private

  def valid_message
    @message = Message.find params[:id]
    unless (@message.user_id == current_user.id || @message.receiver_id == current_user.id)
      render guilty_response
    end
  end

  def valid_section
    params[:section] = 'inbox' unless SECTIONS.include?(params[:section])
  end
end
