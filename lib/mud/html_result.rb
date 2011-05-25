module Mud

  class HtmlResult
    def initialize(html, js)
      @html = html
      @js = js
    end

    def to_s
      doc = html_doc
      script = doc.search('//script').find { |script_tag| /.*\/dev$/.match script_tag.attributes['src'] }

      if script
        script.remove_attribute(:src)
      else
        script = Hpricot::Elem.new('script', :type => 'text/javascript')
        head = doc.at('/html/head')

        unless head
          head = Hpricot::Elem.new('head')
          doc.root.children.unshift(head)
        end

        head.children = (head.children || []).unshift(script)
      end

      script.inner_html = @js.to_s

      doc.to_html
    end

    private

    def html_doc
      Hpricot(Mud.render @html)
    end
  end

end