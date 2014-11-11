# coding: utf-8
module MSP
  class CopyGenerator < Jekyll::Generator
    def generate(site)
      site.config["copy"].each do |copy|
        site.static_files << CopyFile.new(site, site.source, copy["src"], copy["dest"])
      end if site.config["copy"]
    end
  end

  class CopyFile < Jekyll::StaticFile
    def initialize(site, base, src, dest)
      super(site, base, File.dirname(src), File.basename(src))
      @dest = dest
    end

    def destination_rel_dir
      dir = if dest_is_dir?
              @dest
            else
              File.dirname(@dest)
            end
      if @collection
        dir.gsub(/\A_/, '')
      else
        dir
      end
    end
    
    def dest_is_dir?
      File.join(@dest, '') == @dest
    end
  end
end
