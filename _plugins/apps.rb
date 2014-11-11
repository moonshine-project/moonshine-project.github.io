# coding: utf-8
module MSP
  class AppBannerTag < Liquid::Tag
    def initialize(tag_name, app_id, tokens)
      super
      @app_id = app_id.strip
    end

    def render(context)
      site = context.registers[:site]
      app = site.data["apps"][@app_id]
      title = app["title"]["ja"]
      "<a href=\"#{app["url"]}\">この記事は「#{title}」iPhoneアプリケーションの開発に関するものです。<img src=\"#{site.baseurl}#{app["banner"]}\" alt=\"#{title}\"/></a>"
    end

    Liquid::Template.register_tag('app_banner', self)
  end

  class AppLinkTag < Liquid::Tag
    def initialize(tag_name, app_id, tokens)
      super
      @app_id = app_id.strip
    end

    def render(context)
      site = context.registers[:site]
      app = site.data["apps"][@app_id]
      title = app["title"]["ja"]
      "<a href=\"#{app["url"]}\">「#{title}」</a>"
    end

    Liquid::Template.register_tag('app_link', self)
  end
end
