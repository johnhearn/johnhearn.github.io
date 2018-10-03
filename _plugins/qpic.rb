require "open3"

  module Jekyll
    class RenderQpicTag < Liquid::Block
  
      def initialize(tag_name, text, tokens)
        super
        @text = text.strip
      end
  
      def render(context)
        contents = super
        site = context.registers[:site]
        o, s = Open3.capture2("qpic -o #{@text}.png", :stdin_data=>contents)
        # Add the file to the list of static files for the final copy once generated
        st_file = Jekyll::StaticFile.new(site, site.source, "", "#{@text}.png")
        site.static_files << st_file
        "<img src='/#{@text}.png' width='75%'>"
      end
    end
  end
  
  Liquid::Template.register_tag('qpic', Jekyll::RenderQpicTag)