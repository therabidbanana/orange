require 'rubygems'
require 'lib/orange'

class Main < Orange::Core
  def afterLoad
    load(Tester.new)
  end
end

class Tester < Orange::Resource
  def afterLoad
    orange.register(:enroute) do |packet|
      appendHa(packet)
    end
  end
  def appendHa(packet)
    packet.html do |html|
      (html / "li strong" ).append('ha!')
      (html / "banana").each do |item|
        item.swap("<a href='http://www.google.com'>Awesome</a>")
      end
    end
  end
end