require 'optparse'

class SniptCLI
  def initialize(command, arguments)
    commands = ['add', 'exec']
        
    if arguments.last == '--help'
      send(command.to_sym, arguments)
      exit
    end
        
    if arguments.length == 0 && !commands.include?(command)
      send('exec', [command])
    else
      send(command.to_sym, arguments)
    end
  end
  
  def add(arguments)
    snipt = {}
    
    OptionParser.new do |option|
      option.banner = 'usage: snipt add "[code]" [details]'
      
      option.on('-d [description]', String, 'A short description of the snipt.') do |description|
        snipt[:description] = description
      end
      
      option.on('-t [tag1,tag2]', Array, 'A comma seperated list of tags for this snipt.') do |tags|
        snipt[:tags] = tags
      end
      
      option.on('-l [language]', String, "The code\'s lexer, in short or normal form. See Snipt#lexer_for.") do |lexer|
        snipt[:lexer] = (@client.lexer_for(lexer) || lexer)
      end
      
      option.on('-p', 'Whether or not the snipt is public.') do |_public|
        snipt[:public] = _public.to_s.capitalize
      end
      
      option.on('--help', 'Show this message.') do 
        puts option
        exit
      end
      
    end.parse!(arguments)
    
    if (arguments.length / 2) <= 4
      puts "You must provide all fields in order to create a new snipt. Run snipt --help for more information on using this command."
      exit
    end
    
    snipt[:code] = arguments.shift
    
    attempt_login
    
    add_snipt = @client.add(snipt)
    puts add_snipt[:message]
  end
  
  def exec(arguments)
    if arguments.empty?
      puts 'No description entered. Run snipt exec --help for options.'
      exit
    end
    
    prompt = false
    
    OptionParser.new do |options|
      options.banner = "usage:  snipt exec <description> [options]\n\tsnipt <description> [options]"
      
      options.separator ''
      
      options.on('-p', 'Whether or not to prompt the user before running the code.') do |prompt|
        prompt = true
      end
      
      options.on('--help', 'Show this message.') do
        puts options
        exit
      end
    end.parse!(arguments)
    
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
  
  def attempt_login
     username = ask_for_username
     password = ask_for_password

     @client = Snipt.new(username, password)
     @client.detailed_return = true

     unless @client.logged_in?
       puts 'Authentication failed.'
       exit
     end
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