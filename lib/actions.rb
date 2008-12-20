class Snipt
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
      load_snipts
      
      return :successful => true, :message => 'Snipt added successfully.'
    rescue
      return :successful => false, :message => 'An unexpected error occured.'
    end
  end
    
  def update(id_or_snipt, *updates)
    id = id_or_snipt.is_a?(Hash) ? id_or_snipt[:id] : id_or_snipt

    if updates.nil? || updates.empty?
      return :successful => true
    end
    
    if (snipt = @snipts.find {|snipt| snipt[:id] == id.to_s}).nil?
      return :successful => false, :message => 'Snipt not found.'
    end
    
    if updates[0].key?(:id)
      return :successful => false, :message => 'You cannot change the ID of a snipt.'
    end
    
    updated_snipt = snipt.update(updates[0])
    updated_snipt[:tags] = updated_snipt[:tags].join(', ')
    updated_snipt[:public] = updated_snipt[:public].to_s.capitalize
    
    updated_snipt.each do |key, value|
      updated_snipt.delete(key)
      updated_snipt[key.to_s] = value.strip
    end
    
    begin
      update = @agent.post('http://snipt.net/save/', updated_snipt)
      load_snipts
      
      return :successful => true, :message => 'Snipt updated successfully.'
    rescue
      return :successful => false, :message => 'An unexpected error occured.'
    end
  end

  def delete(id_or_snipt)
    id = id_or_snipt.is_a?(Hash) ? id_or_snipt[:id] : id_or_snipt
  
    begin
      @agent.post('http://snipt.net/delete', :id => id)
      load_snipts
    
      return :successful => true, :message => 'Snipt successfully deleted.'
    rescue
      return :successful => false, :message => 'An unexpected error occured.'
    end
  end
end