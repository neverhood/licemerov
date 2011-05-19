module Pagination
  module Controller

    ENTRIES_PER_PAGE = 10
    OFFSET = proc {|page| ((page*ENTRIES_PER_PAGE) - (ENTRIES_PER_PAGE - 1) - 1)}

    private

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
        table = model.to_s.underscore.pluralize
        order = "'#{table}'.created_at DESC"

        if @user
          @page_entries = @user.send(table).offset(OFFSET.call(page)).
            limit(ENTRIES_PER_PAGE).order(order)
        else
          @page_entries = model.offset(OFFSET.call(page)).limit(ENTRIES_PER_PAGE).
            order(order)
        end

        @page_entries = @page_entries.send(:parent) if model.parent_entries?
        @page_entries = @page_entries.send(:with_user_details) if (model.with_user_details?)

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
    end

    def self.included(base)
      base.extend(ClassMethods)
    end


  end
end
