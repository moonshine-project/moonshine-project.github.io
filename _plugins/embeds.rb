# coding: utf-8
module MSP
  class GistItTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @file = text.strip
    end

    def render(context)
      "<script async src=\"http://gist-it.appspot.com/github#{@file}\"></script>"
    end

    Liquid::Template.register_tag('gistit', self)
  end
  
  class ImageTag < Liquid::Block
    def initialize(tag_name, text, tokens)
      super
      @src = text
    end

    def render(context)
      site = context.registers[:site]
      "<img src=\"#{site.baseurl}#{@src}\" alt=\"#{super}\"/>"
    end

    Liquid::Template.register_tag('image', self)
  end

  class AlertTag < Liquid::Block
    def initialize(tag_name, text, tokens)
      super
      @alert_type = text
    end

    def render(context)
      alert_class = if @alert_type
                      "alert-#{@alert_type}"
                    else
                      ""
                    end
      "<p class=\"alert #{alert_class}\">#{super}</p>"
    end

    Liquid::Template.register_tag('alert', self)
  end

  # https://gist.github.com/serra/5574343
  class YouTube < Liquid::Tag
    Syntax = /^\s*([^\s]+)(\s+(\d+)\s+(\d+)\s*)?/
    
    def initialize(tagName, markup, tokens)
      super
      
      if markup =~ Syntax then
        @id = $1
        
        if $2.nil? then
          @width = 560
          @height = 420
        else
          @width = $2.to_i
          @height = $3.to_i
        end
      else
        raise "No YouTube ID provided in the \"youtube\" tag"
      end
    end
    
    def render(context)
      "<iframe width=\"#{@width}\" height=\"#{@height}\" 
        allowfullscreen=\"allowfullscreen\"
        src=\"http://www.youtube.com/embed/#{@id}?color=white&theme=light\"> </iframe>"
    end
    
    Liquid::Template.register_tag "youtube", self
  end
end
