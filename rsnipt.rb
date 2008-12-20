require 'rubygems'
require 'json'
require 'mechanize'

require 'lib/initialize'
require 'lib/actions'
require 'lib/snipt_struct'
require 'lib/snipts'

Snipt.snipts(:date).each do |snipt|
  puts "#{snipt.id} - #{snipt.description} by #{snipt.author} (#{snipt.hash.class})"
  puts "#{snipt.client}"
    
  if (update = snipt.update(:tags => ['date', 'time']))[:successful]
    puts 'Destroyed successfully.'
  else
    puts 'Failed: ' + update[:message]
  end
end

Snipt.new('michaelboutros', 'he1100').public_snipts(:date).each do |snipt|
  puts "#{snipt.id} - #{snipt.description} by #{snipt.author} (#{snipt.hash.class})"
  puts "#{snipt.client}"
    
  if (update = snipt.update(:tags => ['date', 'time']))[:successful]
    puts 'Updated successfully.'
  else
    puts 'Failed: ' + update[:message]
  end
end