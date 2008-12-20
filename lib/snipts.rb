class Snipt  
  class << self
    def snipts(tag = nil, client = nil)
      tag_path = "/tag/#{tag}" if tag
      
      begin
        snipts_page = WWW::Mechanize.new.get("http://snipt.net/public/#{tag_path}")      
        snipts = snipts_page.search('ul.snipts/li').collect {|snipt| parse_snipt(snipt, client)}
      rescue
        []
      end
    end
  end
  
  def load_snipts(tag = nil)
    @snipts.clear
    
    tag_path = "/tag/#{tag}" if tag
    
    begin
      snipts_page = @agent.get("http://www.snipt.net/#{@username}/#{tag_path}")
      
      snipts_page.search('ul.snipts/li').each do |snipt|
        @snipts << self.class.parse_snipt(snipt, self, @username)
      end
    rescue
    end
  end
  
  alias :reload_snipts :load_snipts
  
  def snipts(tag = nil)
    reload_snipts(tag) if tag
    @snipts
  end  
  
  def public_snipts(tag = nil)
    self.class.snipts(tag, self)
  end
  
  protected
    def self.parse_snipt(snipt, client_instance, owner = nil)     
      id = snipt.attributes['class'].scan(/\d+/)[0]
      snipt_hash = {
        :id => id,
        :author => (owner || snipt.at("span.posted-by/a").inner_text),
        :public => snipt.at("p#public-raw-#{id}").inner_text == '0' ? false : true,
        :lexer => snipt.at("pre#lexer-raw-#{id}").inner_text,
        :code => snipt.at("div#code-stylized-#{id}").inner_text,
        :description => snipt.at('span.description').inner_text.delete('∞').strip,
        :tags => snipt.search('ul/li').to_a.collect {|tag| tag.inner_text.delete(',?').strip }
      }
            
      SniptStruct.new(
        client_instance.respond_to?(:username) && client_instance.username == snipt_hash[:author] ? client_instance : self, 
        snipt_hash, 
        snipt_hash[:id],
        snipt_hash[:author],
        snipt_hash[:public],
        snipt_hash[:lexer],
        snipt_hash[:code],
        snipt_hash[:description],
        snipt_hash[:tags]
        )
    end
end