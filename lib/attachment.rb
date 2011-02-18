module Paperclip
  class Attachment

    def geometry(style = :original)
      @geometry ||= {}
      if queued_for_write.blank?
        @geometry[style] ||= File.exists?(path(style)) ? Paperclip::Geometry.from_file(path(style)) : nil
      else
        @geometry[style] ||= Paperclip::Geometry.from_file(queued_for_write[style])
      end
    end

    def dimensions(style = :original)
      @avatar_dimensions ||= instance.avatar_dimensions
      if @avatar_dimensions.is_a?(String)
        @avatar_dimensions = eval(@avatar_dimensions)
      end
      if @avatar_dimensions && @avatar_dimensions[style]
         Paperclip::Geometry.new(@avatar_dimensions[style][:width], @avatar_dimensions[style][:height])
      else
        nil
      end
    end

    def ratio(style1, style2)
      if dimensions(style1) && dimensions(style2)
        dimensions(style1).width / dimensions(style2).width
      else
        nil
      end
    end

    alias :dims :dimensions

  end
end
