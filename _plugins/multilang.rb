# coding: utf-8
module MSP
  class MultilangGenerator < Jekyll::Generator
    def generate(site)
      ensure_lang(site.pages)
      ensure_lang(site.posts)
      assign_alts(site.pages)
      assign_alts(site.posts)
    end

    private

    def assign_alts(pages)
      named_pages = pages.group_by do |page|
        page.data['name']
      end
      pages.each do |page|
        page.data['alts'] = named_pages[page.data['name']] if page.data['name']
      end
    end

    def ensure_lang(pages)
      pages.each do |page|
        page.data['lang'] = 'en' if not page.data['lang']
      end
    end
  end
end
