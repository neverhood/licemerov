class MessagesController < ApplicationController

  SECTIONS = ['sent']
  layout Proc.new { |controller| controller.request.xhr?? false : 'application' }

  before_filter :require_owner, :only => :show
  before_filter :require_user, :only => :new
  before_filter :valid_term, :only => :new # Only hit database with trusted LIKE statement
  before_filter :valid_section, :only => :show
  before_filter :valid_parent, :only => :create
  before_filter :valid_unwanted_message_ids, :only => :update
  before_filter :valid_message, :only => :destroy
  skip_before_filter :existent_user, :only => [:new, :create, :destroy]
  skip_before_filter :delete_messages, :only => [:destroy, :update]


  # Used to autocomplete users login when sending a new message
  #
  def new
    respond_to do |format|
      format.html { @message = Message.new }
      format.json do
        @users = User.friends_of(current_user).where(['users.login LIKE ?', "%#{params[:term]}%"])
        render :json => @users.map { |u|
          {
              :value => u.login,
              :id => u.id,
              :name => u.name,
              :avatar => u.avatar.url(:thumb)
          }
        }
      end
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
    @recipients = params[:message][:recipients].split(',').
        find_all { |id| id =~ /^\d+$/ }
    @recipients = [] unless (1..15).include? @recipients.size

    @messages = @recipients.map { |recipient|
      current_user.messages.build( :body => params[:message][:body],
                                   :subject => params[:message][:subject],
                                   :receiver_id => recipient.to_i,
                                   :parent_id => params[:message][:parent_id] )
    }

    @success = true

    @messages.each {|message| @success = false unless message.save }

    respond_to do |format|
      if @success
        format.json { render :json => { :message => t(:message_created) } }
        format.html { redirect_to :back, :notice => t(:message_created) }
      else
        render guilty_response
      end
    end
  end

  def update # used to mass update messages using checkboxes in view

    @success = true
    @messages.each do |message|
      message.marked_as_deleted = true
      @success = false unless message.save
    end


    respond_to do |format|
      if @success
        format.js { render :json => { :message => t(:messages_deleted) } }
        format.html { redirect_to :back, :notice => t(:messages_deleted) }
      else
        format.js { render :json => t(:failed_to_delete_messages) }
        format.html { redirect_to :back, :notice => t(:failed_to_delete_messages) }
      end
    end
  end

  def destroy

    @message.marked_as_deleted = true

    respond_to do |format|
      if @message.save
        format.json { render :json => { :message => t(:message_deleted), :status => 200 } }
        format.html { redirect_to :back, :notice => t(:message_deleted) }
      else
        format.json { render :json => { :status => 403 }}
        format.html { redirect_to :back }
      end
    end

  end

  def cancel_deletion
    @message.marked_as_deleted = false

    respond_to do |format|
      if @message.save
        format.json { render :json => { :message => t(:message_recovered), :status => 200 } }
        format.html { redirect_to :back, :notice => t(:message_recovered)}
      end
    end
  end

  private

  def valid_term
    if params[:term]
      render guilty_response unless params[:term] =~ /\A\w[\w\.\-_]+$/
    else
      true
    end
  end

  def valid_parent
    if params[:message][:parent_id]
      # Means that current_user should be the one who received or sent parent message ( common sense )
      message = Message.find params[:message][:parent_id]
      (message.user_id == current_user.id || message.receiver_id == current_user.id) ? true : false
    else
      true
    end
  end

  def valid_unwanted_message_ids
    # params[:unwanted_messages] is a string of message id's that user wishes to delete ( using checkboxes in view )
    # we split it by comma, check each supposed id for validness ( should match /^\d+$/ regex[ ), join these back into
    # comma separated string and use it in sql IN statement. Then we check each record if it belongs to current user
    # ( which is the main reason why this before filter exists )

    if params[:unwanted_messages]
      @messages = Message.where(['id IN (?)',
                                 params[:unwanted_messages].split(',')
                                 .find_all { |id| id =~ /^\d+$/ }
                                 .join(',')
                                ])
      .find_all { |message| message.user_id == current_user.id || message.receiver_id == current_user.id }

      render(guilty_response) unless @messages.size > 0

    else
      render :nothing => true
    end
  end

  def valid_message
    # You must be somehow related to the message
    @message = Message.find params[:id]
    unless (@message.user_id == current_user.id || @message.receiver_id == current_user.id)
      render guilty_response # Take that!
    end
  end


  def valid_section
    params[:section] = 'inbox' unless SECTIONS.include?(params[:section])
  end
end
