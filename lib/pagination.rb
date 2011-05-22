module Pagination
  module Controller

    ENTRIES_PER_PAGE = 10
    OFFSET = proc {|page| ((page*ENTRIES_PER_PAGE) - (ENTRIES_PER_PAGE - 1) - 1)}

    private

    def valid_page
      if params[:page] || params[:offset]

        @page_entries = []

        return @page_entries unless (params[:page] || (params[:offset] && params[:id]))

        if params[:offset]
          @type = :response
          @offset = params[:offset]
          @parent_id = params[:id]
        else
          @type = :parent
          @page = params[:page].to_i
        end

        model = case self.class.name
                  when 'MainController' then RootEntry
                  else
                    self.class.name.sub(/Controller/, '').singularize.constantize
                end
        table = model.name.to_s.underscore.pluralize
        views_folder = (table == 'root_entries')? 'main' : table
        order = "'#{table}'.created_at DESC"


        if @type == :response
          @parent_entry = model.send(:find, @parent_id)
          return @page_entries unless @parent_entry

          @page_entries = @parent_entry.children.offset(@offset).order(order)
        else
          if @user || @photo
            @page_entries = (@user || @photo).send(table).offset(OFFSET.call(@page)).
                limit(ENTRIES_PER_PAGE).order(order)
          else
            @page_entries = model.offset(OFFSET.call(@page)).limit(ENTRIES_PER_PAGE).
                order(order)
          end
          @page_entries = @page_entries.send(:parent) if model.parent_entries?
        end


        @page_entries = @page_entries.send(:with_user_details) if (model.with_user_details?)

        local = table.singularize.to_sym

        @page_entries_json = case @type
                               when :parent then {:entries => @page_entries.map {|e| json_for(e)[local]}}
                               when :response then
                                 {:entries => @page_entries.map {|e| render_to_string(:partial => "#{views_folder}/response",
                                                                                      :locals => {local => e})}}
                             end

      end
    end

  end

  module Model

    module ClassMethods

      def with_user_details?
        respond_to? :with_user_details
      end

      def parent_entries?
        respond_to? :parent
      end

      def response_entries?
        respond_to? :response
      end

    end

    def self.included(base)
      base.extend(ClassMethods)
    end


  end
end
