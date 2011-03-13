class MessagesController < ApplicationController

  SECTIONS = ['sent']

  before_filter :require_owner
  before_filter :valid_section, :only => :show
  before_filter :valid_message, :only => [:update, :destroy]
  skip_before_filter :existent_user, :only => [:new, :create, :update, :destroy]
  skip_before_filter :require_owner, :only => :new

  def new
    if current_user
      term = params[:term]
      users = User.friends_of(current_user).where(['users.login LIKE ?', "%#{term}%"])
      render :json => users.map {|u| {:value => u.login, :id => u.login}}
    else
      render :json => 'Please, stop being so adopted'
    end
  end

  def show
    @message = Message.new
    @messages = case params[:section]
                  when 'inbox' then current_user.incoming_messages
                  when 'sent' then current_user.messages
                end
  end

  def create
    @message = current_user.messages.build(params[:message])
    @message.user_login, @message.user_sex = current_user.login, current_user.sex
    respond_to do |format|
      if @message.save
        format.js { render :json => {:message => t(:message_created), :html_class => :notice } }
        format.html { redirect_to :back, :notice => t(:message_created) }
      else
        format.js { render :json => @message.errors, :status => :unprocessable_entity  }
        redirect_to :back, :flash => { :errors => @message.errors } # TODO: before filter to show errors in all possible places
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
    unless (@message.user_id == current_user.id || @message.receiver_id == current_ser.id)
      render guilty_response
    end
  end

  def valid_section
    params[:section] = 'inbox' unless SECTIONS.include?(params[:section])
  end
end
