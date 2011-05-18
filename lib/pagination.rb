module Pagination
  module Controller

    ENTRIES_PER_PAGE = 10
    OFFSET = proc {|page| ((page*ENTRIES_PER_PAGE) - (ENTRIES_PER_PAGE - 1))}

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

        @page_entries = model.offset(OFFSET.call(page)).limit(ENTRIES_PER_PAGE).
          order("'#{model.to_s.underscore.pluralize}'.created_at DESC")
        @page_entries = @page_entries.send(:with_user_details) if (model.with_user_details?)

      end
    end
  end

  module Model

    module ClassMethods
      def with_user_details?
        respond_to? :with_user_details
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end


  end
end
