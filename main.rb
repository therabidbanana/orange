require 'rubygems'
require 'lib/orange'

class Main 
  def initialize(core = false)
    @core = core
  end
  
  def afterLoad
  end
  
  def call(env)
    packet = Orange::Packet.new(@core, env)
    packet.route
    return packet.finish
    raise 'lol'
    [200, {"Content-Type" => 'text/html'}, ["Test"]]
  end
  
  def self.app
    require 'stack'
    Orange::Stack.new &@app
  end
  
  def self.stack(&block)
    @app = Proc.new
  end
end

class Tester < Orange::Resource
  def afterLoad
    # orange.register(:enroute, 100) do |packet|
    #   appendHah(packet)
    # end
  end
  
  def appendHah(packet)
    # packet.html do |html|
    #   (html / "banana").each { |item|
    #     item.swap("<a href='http://www.google.com'>Awesome</a>")
    #   }
    # end
  end
end


class Page < Orange::Carton
  id
  front do
    title :title
    fulltext :body
  end
  admin do
    text :admin_only
  end
  orange do
    text :other_admin
  end
end

class Page_Resource < Orange::ModelResource
  use Page
  def afterLoad
    orange.register(:view_admin) do |packet|
      packet.admin_sidebar_link("CONTENT", :text => "Pages", :link => packet.route_to(@my_orange_name, 'list'))
    end
  end
end

# Orange::load_db!("sqlite3://#{Dir.pwd}/db/orangerb.sqlite3")
# Page.auto_migrate!

# 
# class Orange_Page < Orange::ModelResource
#   use Page
# end
