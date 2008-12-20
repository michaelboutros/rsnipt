require 'rubygems'
require 'json'
require 'mechanize'

require 'lib/initialize'
require 'lib/actions'
require 'lib/snipts'

Snipt.snipts(:ruby).each do |snipt|
  puts "#{snipt[:id]} - #{snipt[:description]}"
end