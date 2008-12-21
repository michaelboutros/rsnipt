require 'rsnipt'

client = Snipt.new('username', 'password')
client.detailed_return = true

if client.logged_in?
  client.snipts # all of the user's snipts
  # => [SniptStruct, SniptStruct, etc.]
  
  client.snipts(:ruby) # all of the user's snipts that include the 'ruby' tag
  # => [SniptStruct, SniptStruct, etc.]
  
  # There are two ways to edit or remove any snipt. Directly on the SniptStruct,
  # or through the client.
  snipt = client.snipts(:ruby).first # => SniptStruct
  
  # Directly on the object.
  destroy = snipt.destroy # => { :successful => true|false, :message => String }
  if destroy[:successfull]
    # do something
  else
    puts destroy[:message]
    # do something else
  end
  
  # Through the client.
  update = client.update(snipt.id, :tags => ['ruby', 'gems'], :public => true) 
  # => { :successful => true|false, :message => String }
  
  if update[:successfull]
    # do something
  else
    puts update[:message]
    # do something else
  end
  
  # Adding a client is equally easy, and can be done through the client. All fields are required.
  client.add(:description => 'A test API call.', :code => "puts 'Hello from the API!'", :lexer => client.lexers['ruby'], :tags => ['ruby', 'snipts'], :public => true)
  # => { :successful => true|false, :message => String }
else
  puts "Authentication failed."
end
