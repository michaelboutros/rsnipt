class SniptStruct < Struct.new(:client, :hash, :id, :author, :public, :lexer, :code, :description, :tags)
  def update(*updates)
    if owned_by?(client)
      client.update(self, updates[0])
    else
      { :successfull => false, :message => 'Cannot update other user\'s snipts.' }
    end
  end
  
  def destroy
    if owned_by?(client)
      client.destroy(self) 
    else
      { :successfull => false, :message => 'Cannot delete other user\'s snipts.' }
    end
  end
  alias :delete :destroy
  
  private
    def owned_by?(client)
      client.respond_to?(:username) && client.username == author
    end
end