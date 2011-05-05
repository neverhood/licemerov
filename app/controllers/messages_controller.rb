class MessagesController < ApplicationController

  SECTIONS = ['sent']
  layout Proc.new { |controller| controller.request.xhr?? false : 'application' }

  before_filter :require_owner, :only => :index
  before_filter :require_user, :only => :new
  before_filter :valid_term, :only => :new # Only hit database with trusted LIKE statement
  before_filter :valid_section, :only => :index
  before_filter :valid_parent, :only => :create
  before_filter :valid_message_ids, :only => [:destroy, :recover, :update]
  skip_before_filter :existent_user, :only => [:new, :create, :destroy, :recover, :update]
  skip_before_filter :delete_messages, :only => [:destroy, :update, :recover]



  def index
    @message = Message.new
    @messages = case params[:section]
                  when 'inbox' then current_user.incoming_messages
                  when 'sent' then current_user.messages
                end
  end

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
    @message = Message.find params[:id]
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

    @success, @errors = true, Array.new

    @messages.each {|message| @success, @errors = false, message.errors unless message.save }

    respond_to do |format|
      if @success
        format.json { 
          render :json => { :message => t(:message_created), :html_class => :notice }
        }
        format.html { redirect_to :back, :notice => t(:message_created) }
      else
        format.json {
          render :json => { :errors => @errors.values.map(&:first), :html_class => :alert },
            :status => :unprocessable_entity
        }
      end
    end
  end

  def update # used to mass update messages using checkboxes in view

    @messages.each do |message|
      message.read = true
      message.save
    end

    respond_to do |format|
      format.json { render :json => {:hello => 'test'}, :status => 200 } 
      format.html { redirect_to :back }
    end

  end

  def destroy

    @messages.each do |message|
      message.marked_as_deleted = true
      message.save
    end

    # We only respond with translated urlText ( to not hardcode russian into js ), the link is then
    # crafted with $.licemerov.utils.linkTo(). Somewhat clumsy hence we should think of a better option

    respond_to do |format|
      format.json { render :json => { :single => t(:cancel), :multiple => t(:recover_messages) }, :status => 200 }
      format.html { redirect_to :back }
    end

  end

  def recover

    @messages = current_user.messages.deleted if params[:id].to_s == 'all'

    @messages.each do |message|
      message.marked_as_deleted = false
      message.save
    end

    # We only respond with translated urlText ( to not hardcode russian into js ), the link is then
    # crafted with $.licemerov.utils.linkTo(). Somewhat clumsy hence we should think of a better option

    respond_to do |format|
      format.json { render :json => { :url_text => t(:recover_messages) }, :status => 200  }
      format.html { redirect_to :back, :notice => t(:message_recovered)}
    end

  end

  private

  def valid_term
    if params[:term]
      render guilty_response unless params[:term] =~ /\A\w[\w\.\-_]+$/
    end
  end

  def valid_parent
    if params[:message][:parent_id]
      # Means that current_user should be the one who received or sent parent message ( common sense )
      render guilty_response unless
          Message.of(current_user).where( :id => params[:message][:parent_id] ).count > 0
    end
  end

  def valid_message_ids
    # params[:id] is a string that may  containt 1 or  more message id's that user wishes to delete
    # or mark as read ( using checkboxes in view )
    # we split it by comma, check each supposed id for validness ( should match /^\d+$/ regex[ ), join these back into
    # comma separated string and use it in sql IN statement.

    if params[:id]
      @messages = Message.of(current_user)
      .where(['id IN (?)',
              params[:id].split(',')
              .find_all { |id| id =~ /^\d+$/ }
             ])

      render(guilty_response) unless (@messages.size > 0 || params[:id].to_s == 'all')

    else
      render :nothing => true
    end
  end

  def valid_section
    params[:section] = 'inbox' unless SECTIONS.include?(params[:section])
  end
end

