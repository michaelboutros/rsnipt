class Snipt
  attr_reader :lexers
  
  def initialize(username, password, user_agent_alias = 'Mac FireFox')    
    @agent = WWW::Mechanize.new    
    @agent.user_agent_alias = user_agent_alias
    
    @username = username
    
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
    
    login_page = @agent.submit(login_form, login_form.buttons.first)
    
    if login_page.at('form.login-form')
      return @logged_in = false
    else
      load_lexers
      
      return @logged_in = true
    end
  end
  
  def logged_in?
    @logged_in
  end
  
  private
    def load_lexers
      @agent.get('http://snipt.net').search("select#lexer-0//option").each do |option|
        @lexers[option.attributes['value']] = option.inner_text
      end
    end
end