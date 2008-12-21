class SniptStruct < Struct.new(:client, :hash, :id, :author, :public, :lexer, :code, :description, :tags)
  def update(*updates)
    if owned_by?(client)
      client.update(self, updates[0])
    else
      custom_return :successfull => false, :message => 'Cannot update other user\'s snipts.'
    end
  end
  
  def destroy
    if owned_by?(client)
      client.destroy(self) 
    else
      custom_return :successfull => false, :message => 'Cannot delete other user\'s snipts.'
    end
  end
  alias :delete :destroy
  
  alias :full_inspect :inspect
  def inspect
    client_string = client.instance_of?(Snipt) ? 'Snipt (instance)' : 'Snipt (class)'
    "#<SniptStruct client=#{client_string}, id=#{id.inspect}, author=#{author.inspect}, public=#{public.inspect}, lexer=#{lexer.inspect}, code=#{code.inspect}, description=#{description.inspect}, tags=#{tags.inspect}>"
  end
  alias :to_s :inspect
  
  def public?
    self.public
  end
  
  private
    def owned_by?(client)
      client.respond_to?(:username) && client.username == author
    end
end