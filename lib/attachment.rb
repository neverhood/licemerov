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
      model = instance.class.name.downcase
      model = 'avatar' if model == 'user'      # stupid workaround
      attribute = model + '_dimensions'
      @image_dimensions ||= instance.send(attribute.to_sym)
      if @image_dimensions.is_a?(String)
        @image_dimensions = eval(@image_dimensions)
      end
      if @image_dimensions && @image_dimensions[style]
         Paperclip::Geometry.new(@image_dimensions[style][:width], @image_dimensions[style][:height])
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
