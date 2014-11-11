# coding: utf-8
module MSP
  module Filters
    # backported from liquid v3.0.0
    def slice(input, offset, length=nil)
      offset = Integer(offset)
      length = length ? Integer(length) : 1

      if input.is_a?(Array)
        input.slice(offset, length) || []
      else
        input.to_s.slice(offset, length) || ''
      end
    end
  end
  Liquid::Template.register_filter(Filters)
end
