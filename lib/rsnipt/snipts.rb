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
    tag_path = "/tag/#{tag}" if tag
  
    begin
      snipts_page = @agent.get("http://www.snipt.net/#{@username}/#{tag_path}")
      
      snipts = snipts_page.search('ul.snipts/li').collect do |snipt|
        self.class.parse_snipt(snipt, self, @username)
      end
      
      snipts
    rescue
      []
    end
  end
  
  def reload_snipts(tag = nil)    
    @snipts.clear
    @snipts = load_snipts(tag)
  
    return @snipts
  end
  
  def snipts(tag = nil)
    reload_snipts(tag)
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
        :permalink => 'http://www.snipt.net' + snipt.at('span.description/a').attributes['href'].to_s,
        :public => snipt.at("p#public-raw-#{id}").inner_text == '0' ? false : true,
        :lexer => snipt.at("pre#lexer-raw-#{id}").inner_text,
        :code => snipt.at("div#code-stylized-#{id}/div").inner_text,
        :description => snipt.at('span.description').inner_text.delete('∞').strip,
        :tags => snipt.search('ul/li').to_a.collect {|tag| tag.inner_text.delete(',?').strip }
      }
            
      SniptStruct.new(
        client_instance.respond_to?(:username) && client_instance.username == snipt_hash[:author] ? client_instance : self, 
        snipt_hash, 
        snipt_hash[:id],
        snipt_hash[:author],
        snipt_hash[:permalink],
        snipt_hash[:public],
        snipt_hash[:lexer],
        snipt_hash[:code],
        snipt_hash[:description],
        snipt_hash[:tags]
      )
    end
end