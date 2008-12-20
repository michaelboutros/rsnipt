class Snipt  
  class << self
    def snipts(tag = nil)
      tag_path = "/tag/#{tag}" if tag
      snipts_page = WWW::Mechanize.new.get("http://snipt.net/public/#{tag_path}")
      
      snipts = snipts_page.search('ul.snipts/li').collect {|snipt| parse_snipt(snipt)}
    end
  end
  
  def load_snipts(tag = nil)
    @snipts.clear
    
    tag_path = "/tag/#{tag}" if tag    
    snipts_page = @agent.get("http://www.snipt.net/#{@username}/#{tag_path}")
    
    snipts_page.search('ul.snipts/li').each do |snipt|
      @snipts << self.class.parse_snipt(snipt)
    end
  end
  
  def snipts(tag = nil)
    load_snipts(tag) if tag
    @snipts
  end  
  
  def public_snipts(tag = nil)
    self.class.snipts(tag)
  end
  
  protected
    def self.parse_snipt(snipt)
      id = snipt.attributes['class'].scan(/\d+/)[0]

      {
        :id => id,
        :description => snipt.at('span.description').inner_text.delete('∞').strip,
        :tags => snipt.search('ul/li').to_a.collect {|tag| tag.inner_text.delete(',?').strip },
        :lexer => snipt.at("pre#lexer-raw-#{id}").inner_text,
        :public => snipt.at("p#public-raw-#{id}").inner_text == '0' ? false : true,
        :code => snipt.at("div#code-stylized-#{id}").inner_text
      }    
    end
end