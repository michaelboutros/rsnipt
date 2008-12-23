require 'optparse'
require 'base64'

class SniptCLI
  def initialize(command, arguments)
    self.extend(SniptCLICommands)
        
    if arguments.last == '--help'
      send(command.to_sym, arguments)
      exit
    elsif arguments.length == 0 && !COMMANDS.include?(command)
      send('exec', [command])
      exit
    else
      send(command.to_sym, arguments)
      exit
    end
  end
  
  def attempt_login(ask = false)    
    if File.exists?(credentials_file) && !ask
      username, password = *File.read(credentials_file).split(': ')
      password = Base64.decode64(password)
      
      @client = Snipt.new(username, password)
      
      unless @client.logged_in?
        puts 'Stored credentials not authenticated. Enter new credentials:'
        attempt_login(true)
      end
    else
      username = ask_for_username
      password = ask_for_password
    
      @client = Snipt.new(username, password)

      if @client.logged_in?
        create_credentials_for(username, password)
      else
        puts 'Authentication failed.'
        exit
      end
    end
    
    @client.detailed_return = true
  end
  
  def credentials_file
    "#{ENV['HOME']}/.snipt/credentials"
  end
  
  def set_credential_permissions
		FileUtils.chmod 0700, File.dirname(credentials_file)
		FileUtils.chmod 0600, credentials_file
  end
  
  def create_credentials_for(username, password)
		FileUtils.mkdir_p(File.dirname(credentials_file))
		
  	File.open(credentials_file, 'w') do |f|
  		f.puts "#{username}: #{Base64.encode64(password)}"
  	end
  	
  	set_credential_permissions
  end
  
  def destroy_credentials
    File.delete(credentials_file)
  end

  def ask_for_username
    print 'Your Snipt username: '
    return gets.strip
  end

  def ask_for_password
    print 'And your password: '
    system "stty -echo"
    password = gets.strip
    system "stty echo"
    puts  
    
    return password
   end
end

module SniptCLICommands
  def add(arguments)
    snipt = {}
    snipt[:code] = arguments.shift
    
    if arguments.empty?
      add(['--help'])
    elsif (arguments.length / 2) < 4
      puts "You must provide all fields in order to create a new snipt. Run snipt --help for more information on using this command."
      exit
    end
    
    attempt_login
    
    OptionParser.new do |options|
      options.banner = 'usage: snipt add "[code]" [details]'
      
      options.on('-d [description]', String, 'A short description of the snipt.') do |description|
        snipt[:description] = description
      end
      
      options.on('-t [tag1,tag2]', Array, 'A comma seperated list of tags for this snipt.') do |tags|
        snipt[:tags] = tags
      end
      
      options.on('-l [language]', String, "The code\'s lexer, in short or normal form. See Snipt#lexer_for.") do |lexer|
        snipt[:lexer] = (@client.lexer_for(lexer) || lexer)
      end
      
      options.on('-p', 'Whether or not the snipt is public.') do |_public|
        snipt[:public] = _public.to_s.capitalize
      end
      
      options.on('--help', 'Show this message.') do 
        puts options
        exit
      end
      
    end.parse!(arguments)
    
    add_snipt = @client.add(snipt)
    puts add_snipt[:message]
  end
  
  def update(arguments)    
    if arguments.empty?
      update(['--help'])
      exit
    else
      description = arguments.shift
      
      if arguments.empty?
        puts 'No updates provided, snipt not updated.'
        exit
      end
    end
    
    attempt_login
    
    snipt = @client.snipts.find {|snipt| snipt.description == description}
    if snipt.nil?
      puts "Snipt #{description.inspect} not found."
      exit
    end
    
    snipt_updates = {}
    OptionParser.new do |options|
      options.banner = "usage: snipt update [description] <updates>"
      
      options.on('-d [description]', '--description [description]', String, 'The snipt\'s description.') do |description|
        snipt_updates[:description] = description
      end
      
      options.on('-t [tag1,tag2]', '--tags [tag1,tag2]', Array, 'The snip\'s tags.') do |tags|
        snipt_updates[:tags] = tags
      end
      
      options.on('-l [language]', '--lexer [language]', String, 'The snipt\'s lexer.') do |lexer|
        snipt_updates[:lexer] = (@client.lexer_for(lexer) || lexer)
      end
      
      options.on('-p [public]', '--public [public]', 'Whether or not the snipt is public.') do |_public|
        snipt_updates[:public] = _public.to_s.capitalize
      end
            
      options.on('--help', 'Show this message.') do
        puts options
        exit
      end   
    end.parse(arguments)
    
    puts snipt.update(snipt_updates)[:message]
  end
  
  def exec(arguments)
    prompt = false
    
    OptionParser.new do |options|
      options.banner = "usage:  snipt exec <description> [options]\n\tsnipt <description> [options]"
      
      options.on('-p', 'Whether or not to prompt the user before running the code.') do |prompt|
        prompt = true
      end
      
      options.on('--help', 'Show this message.') do
        puts options
        exit
      end
    end.parse!(arguments)
    
    if arguments.empty?
      exec(['--help'])
      exit
    end
    
    puts 'Logging in...'
    attempt_login
    
    snipt = @client.snipts.find {|snipt| snipt.description == arguments.first }
    
    if snipt.nil?
      puts "Snipt '#{arguments.first}' not found."
      exit   
    else 
      if prompt    
        print "Snipt found: are you sure you want to execute? (yn) "
        execute = gets.strip
      
        if execute == 'y'
          system snipt.code
        else
          exit
        end
      else
        system snipt.code
      end
    end
  end
  
  def user(arguments)
    OptionParser.new do |options|
      options.banner = 'usage: snipt user [options]'
      
      options.on('--login', 'Login with a new user.') do
        create_credentials_for(ask_for_username, ask_for_password)
        
        puts 'Credentials saved.'
      end
      
      options.on('--flush', 'Flush the old user and prompt for new credentials.') do
        puts 'Flushing old credentials...'
        destroy_credentials
        
        puts 'Enter new information: '        
        create_credentials_for(ask_for_username, ask_for_password)
        
        puts 'New credentials saved.'
      end
      
      options.on('--show', 'Show the current stored credentials.') do
        username, password = *File.read(credentials_file).split(': ')
        puts "Current user: #{username}"
      end
      
      options.on('--help', 'Show this message.') do
        puts options
        exit
      end
    end.parse(arguments)
    
    if arguments.empty?
      user(['--show'])
    end
  end
end