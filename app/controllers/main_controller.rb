class MainController < ApplicationController

  ENTRIES_PER_PAGE = 10
  OFFSET = proc {|page| ((page*ENTRIES_PER_PAGE) - (ENTRIES_PER_PAGE - 1))}
  #include Pagination::Controller

  skip_before_filter :existent_user

  before_filter :require_user, :only => [:create, :update, :destroy]
  before_filter :valid_comment, :only => [:update, :destroy]
  before_filter :valid_page, :only => :show

  def index
    @entries = RootEntry.with_user_details.where(:parent_id => nil).
        order('"root_entries".created_at DESC').
        limit(10)
    @entry = RootEntry.new
  end

  def show
    respond_to do |format|
      format.json do
        render :json => {:entries => @page_entries.map {|e| json_for(e)[:root_entry]}}
      end
    end
  end

  def create
    @entry = RootEntry.new(params[:root_entry])
    @entry.user_id = current_user.id
    @entry.save
    @entry_with_user_details = RootEntry.with_user_details.where(:id => @entry.id).first
    respond_to do |format|
      format.html { redirect_to '/'}
      format.js {render :layout => false}
    end

  end

  def update

  end

  def destroy
    respond_to do |format|
      if @entry.destroy
        format.json { render :json => {:message => t(:comment_deleted), :html_class => :warning} }
        format.html { redirect_to :back, :flash => {:warning => t(:comment_deleted)} }
      else
        render :nothing => true
      end
    end
  end

  private

  def valid_comment
    if params[:id] || params[:root_entry]
      @entry = current_user.root_entries.where(:id => params[:id]).first
      render guilty_response unless @entry
    end
  end

  def valid_page
    if params[:page]
      @page_entries = []
      page = params[:page].to_i

      return false unless page > 0

      model = case self.class.name
                when 'MainController' then RootEntry
                else self.class.name.sub(/Controller/, '').
                    singularize.constantize
              end

      @page_entries = model.order("'#{model.to_s.underscore.pluralize}'.created_at DESC").
          offset(OFFSET.call(page)).limit(ENTRIES_PER_PAGE)
      @page_entries = @page_entries.send(:with_user_details) if (model.with_user_details?)

    end
  end

end
