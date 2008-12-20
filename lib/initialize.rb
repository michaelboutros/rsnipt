class Snipt
  attr_accessor :detailed_returns
  attr_reader :lexers, :username
  
  # Takes the username and password of the user that will be logged in.
  def initialize(username, password)    
    @detailed_returns = true
    
    @agent = WWW::Mechanize.new    
    @agent.user_agent_alias = 'Mac FireFox'
    
    @username = username
    
    @logged_in = false
    @lexers = {}
    
    login(username, password)
    @snipts = load_snipts
  end
  
  def custom_return(input) # :nodoc:
    return self.detailed_returns ? input : input[:successful]
  end
  
  def login(username, password) # :nodoc:
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
  
  # Returns true if the user logged in successfully.
  def logged_in?
    @logged_in
  end
  
  # Returns the lexer's "short form" of the language, as defined by Snipt.net. For example:
  #   client.lexer_for('C++') # => 'cpp'
  #   client.lexer_for('gibberish') => nil
  def lexer_for(language)
    self.lexers.find {|short, lang| language == lang}
  end
  
  private
    def load_lexers # :nodoc:
      @agent.get('http://snipt.net').search("select#lexer-0//option").each do |option|
        @lexers[option.attributes['value']] = option.inner_text
      end
    end
end