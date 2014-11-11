# coding: utf-8
module MSP
  class ProjectGenerator < Jekyll::Generator
    def generate(site)
      site.data["projects"].each do |project|
        project["date"] = Time.parse(project["date"])
      end
    end
  end
  class SeasonTag < Liquid::Tag
    def initialize(tag_name, variable, tokens)
      super
      @variable = variable.strip
    end

    def render(context)
      date = lookup(context, @variable)
      t(context, :short_season)[season(date.month)]
    end

    private

    def lookup(context, variable)
      variable.split('.').inject(context) do |memo,each|
        memo[each]
      end
    end

    def t(context, key)
      lang = context.registers[:page]['lang']
      context.registers[:site].data['strings'][lang][key.to_s]
    end

    def season(month)
      case month
      when 1..2 then :winter
      when 3..5 then :spring
      when 6..8 then :summer
      when 9..11 then :autumn
      when 12 then :winter
      end.to_s
    end

    Liquid::Template.register_tag('season', self)
  end
end
