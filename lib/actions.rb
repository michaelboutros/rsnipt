class Snipt
  
  # This method is used to add snipts directly to a user's account through the client instance. 
  # The following fields are _required_, and if they are not given then the snipt will not be created:
  # * +code+: The code or command that makes up the body of the snipt.
  # * +description+: A short description of what this snipt does.
  # * +tags+: An Array of tags that describe the snipt.
  # * +public+: A boolean of whether or not the snipt is to be public.
  # * +lexer+: The language of this snipt. For more information on lexer's and how to use them in the scope
  #   of this library, look at Snipt#load_lexers.
  #
  # On success, #add will simply return:
  #   {:successfull => true, :message => 'Snipt added successfully.'} 
  # 
  # On fail, #add will return more information in the form of a descriptive error message, such as:
  #   {:successfull => false, :message => 'All fields are required.'}
  def add(snipt)
    snipt[:id] = '0'
   
    begin 
      snipt[:tags] = snipt[:tags].join(', ')
      snipt[:public] = snipt[:public].to_s.capitalize
    
      snipt.each do |key, value|
        snipt.delete(key)
        snipt[key.to_s] = value.strip
      end
    rescue NoMethodError
      return :successful => false, :message => 'All fields are required.'
    end
    
    begin
      @agent.post('http://snipt.net/save/', snipt)
      reload_snipts
      
      return :successful => true, :message => 'Snipt added successfully.'
    rescue
      return :successful => false, :message => 'An unexpected error occured.'
    end
  end
    
  # This method is used to update a snipt directly through the client interface. This method takes:
  # * +id+ or +snipt+: Either the id of the snipt, or the SniptStruct instance itself.
  # * +updates+: A hash containing the updated field values. Note that this will completely rewrite each field,
  #   so if you want to add a tag, you have to pass the entire tags array, plus the new tag. For example:
  # 
  #     snipt = client.snipts(:ruby).first
  #     snipt.tags # => ['ruby', 'library', 'date']
  # 
  #     client.update(snipt, :tags => (snipt.tags << 'time'))
  # 
  # On success, this method will simply return true and a message:
  #   {:successfull => true, :message => 'Snipt updated successfully.'}
  # 
  # On failure, the method will return false as well as a more descriptive message, such as:
  #   {:successful => false, :message => 'Snipt not found.'}
  def update(id_or_snipt, *updates)
    id = id_or_snipt.is_a?(Struct) ? id_or_snipt.id : id_or_snipt

    if updates.nil? || updates.empty?
      return :successful => true
    end
    
    if (snipt = @snipts.find {|snipt| snipt[:id] == id.to_s}).nil?
      return :successful => false, :message => 'Snipt not found.'
    end
    
    if updates[0].key?(:id)
      return :successful => false, :message => 'You cannot change the ID of a snipt.'
    end
    
    updated_snipt = (snipt.hash).update(updates[0])
    updated_snipt[:tags] = updated_snipt[:tags].join(', ')
    updated_snipt[:public] = updated_snipt[:public].to_s.capitalize
    
    updated_snipt.each do |key, value|
      updated_snipt.delete(key)
      updated_snipt[key.to_s] = value.strip
    end
    
    begin
      update = @agent.post('http://snipt.net/save/', updated_snipt)
      reload_snipts
      
      return :successful => true, :message => 'Snipt updated successfully.'
    rescue
      return :successful => false, :message => 'An unexpected error occured.'
    end
  end

  # This method simply destroys the snipt given. Like with update, you can either
  # pass the snipt's id or the SniptStruct instance.
  def destroy(id_or_snipt)
    id = id_or_snipt.is_a?(Struct) ? id_or_snipt.id : id_or_snipt
  
    begin
      @agent.post('http://snipt.net/delete', :id => id)
      reload_snipts
    
      return :successful => true, :message => 'Snipt successfully deleted.'
    rescue
      return :successful => false, :message => 'An unexpected error occured.'
    end
  end
  alias :delete :destroy
end