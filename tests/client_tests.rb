require File.dirname(__FILE__) + '/../lib/rsnipt.rb'
require 'shoulda'

require 'test/unit'
require 'rubygems'
require 'mocha'

class MiscExampleTest < Test::Unit::TestCase
  context "Using the client with a logged in user" do
    should "log in valid user" do
      client = Snipt.new('username', 'password')
      client.expects(:logged_in?).returns(true)
      
      assert client.logged_in?
    end
    
    should "not log in invalid user" do
      client = Snipt.new('invalid_username', 'invalid_password')
      client.expects(:logged_in?).returns(false)
      
      assert !client.logged_in?
    end
    
    should "return username" do
      client = Snipt.new('johnsmith', 'thepassword')
      assert client.username == 'johnsmith'
    end
  end
end