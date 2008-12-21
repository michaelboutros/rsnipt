require 'optparse'

class SniptCLI
  def initialize(command, arguments)
    commands = ['add', 'exec']
        
    if arguments.last == '--help'
      send(command.to_sym, arguments)
      exit
    end
        
    ask_for_username
    ask_for_password
    
    @client = Snipt.new(@username, @password)
    @client.detailed_return = true
    
    if @client.logged_in?
      if arguments.length == 0
        send('exec', [command])
      else
        send(command.to_sym, arguments)
      end
    else
      puts 'Authentication failed.'
      exit
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
      
      option.on('-p [true|false]', String, 'Whether or not the snipt is public.') do |_public|
        snipt[:public] = _public.to_s.capitalize
      end
      
      option.on('--help', 'Show this message.') do 
        puts option
        exit
      end
      
    end.parse!(arguments)
    
    snipt[:code] = arguments.shift
    
    unless (arguments.length / 2) < 4
      puts "You must provide all fields in order to create a new snipt. Run snipt --help for more information on using this command."
      exit
    end
    
    add_snipt = @client.add(snipt)
    puts add_snipt[:message]
  end
  
  def exec(description)
    snipt = @client.snipts.find {|snipt| snipt.description == description.first }
    
    if snipt.nil?
      print "\nSnipt '#{description}' not found."
      exit
    else
      print "\nSnipt found: are you sure you want to execute? (yn) "
      execute = gets.strip
      
      if execute == 'y'
        system snipt.code
      else
        exit
      end
    end
  end
  
  def ask_for_username
    print 'Your Snipt username: '
    @username = gets.strip
  end
  
  def ask_for_password
    print 'And your password: '
    system "stty -echo"
    @password = gets.strip
    system "stty echo"    
  end
end