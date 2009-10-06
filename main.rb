require 'rubygems'

require 'lib/orange'

class Main < Orange::Core
  
  def afterLoad
    load(Tester.new)
    load(Page_Resource.new, :pages)
  end
end

class Tester < Orange::Resource
  def afterLoad
    orange.register(:enroute) do |packet|
      appendHa(packet)
    end
  end
  
  def appendHa(packet)
    # packet.html do |html|
    #   # (html / "li strong" ).append('foo')
    #   (html / "banana").each do |item|
    #     item.swap("<a href='http://www.google.com'>Awesome</a>")
    #   end
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
  as_resource
end

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/orangerb.sqlite3")
Page.auto_migrate!


# 
# class Orange_Page < Orange::ModelResource
#   use Page
# end
