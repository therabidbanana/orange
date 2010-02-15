class PageResource < Orange::ModelResource
  use Page
  call_me :pages
  def afterLoad
    orange[:admin, true].add_link("Content", :resource => @my_orange_name, :text => 'Pages')
    options[:sitemappable] = true
  end
end