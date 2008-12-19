require 'rubygems'
require 'json'
require 'mechanize'

class Snipt  
  attr_reader :lexers, :snipts
  
  def initialize(username, password, user_agent_alias = 'Mac FireFox')
    @agent = WWW::Mechanize.new
    @agent.user_agent_alias = user_agent_alias
    
    @logged_in = false
    @lexers = {}
    @snipts = []
    
    login(username, password)
    load_snipts
  end
  
  def login(username, password)
    login_form = @agent.get('http://www.snipt.net/login').forms.first
        
    login_form.username = username
    login_form.password = password
    
    login = @agent.submit(login_form, login_form.buttons.first)
    
    if login.at('form.login-form')
      return @logged_in = false
    else
      login.search("select#lexer-0//option").each do |option|
        @lexers[option.attributes['value']] = option.inner_text
      end
      
      return @logged_in = true
    end
  end
  
  def logged_in?
    @logged_in
  end

  def load_snipts(tag = :*, amount = 20)
    snipts_page = @agent.get("http://www.snipt.net/#{@username}")
    
    snipts_page.search('ul.snipts/li').each do |snipt|
      id = snipt.attributes['class'].scan(/\d+/)[0]
      
      @snipts << {
        :id => id,
        :description => snipt.at('span.description').inner_text.delete('∞').strip,
        :tags => snipt.search('ul/li').to_a.collect {|tag| tag.inner_text.delete(',?').strip },
        :lexer => snipt.at("pre#lexer-raw-#{id}").inner_text,
        :public => snipt.at("p#public-raw-#{id}").inner_text == '0' ? false : true,
        :code => snipt.at("div#code-stylized-#{id}").inner_text
      }
    end
  end
  
  def update(id_or_snipt, *updates)
    id = id_or_snipt.is_a?(Hash) ? id_or_snipt[:id] : id_or_snipt

    if updates.nil? || updates.empty?
      return :success => true
    end
    
    if (snipt = @snipts.find {|snipt| snipt[:id] == id.to_s}).nil?
      return :success => false, :message => 'Snipt not found.'
    end
    
    if updates[0].key?(:id)
      return :success => false, :message => 'You cannot change the ID of a snipt.'
    end
    
    # snipts_page = @agent.get("http://www.snipt.net/#{@username}")
    # snipt_node = snipts_page.at("li.container-#{id}")
    
    updated_snipt = snipt.update(updates[0])
    updated_snipt[:tags] = updated_snipt[:tags].join(',+')
    updated_snipt[:public] = updated_snipt[:public].to_s.capitalize
    
    ['description', 'lexer', 'code'].each do |key|
      updated_snipt[key.to_sym] = updated_snipt[key.to_sym].to_s.gsub(/ /, '+')
      end
    
    updated_snipt.each do |key, value|
      updated_snipt.delete(key)
      updated_snipt[key.to_s] = value.strip
    end
    
    puts updated_snipt.inspect
    
    update = @agent.post('http://www.snipt.net/save/', updated_snipt.to_json)
    
    return :success => true, :message => ''
  end
end