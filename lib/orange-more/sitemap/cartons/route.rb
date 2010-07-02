require 'orange-more/administration/cartons/site_carton'
require 'dm-is-awesome_set'

class OrangeRoute < Orange::SiteCarton
  id
  admin do
    text :slug, :display_name => "Search Engine Friendly Page URL", :length => 255
    text :link_text, :length => 255
    text :reroute_to, :length => 255
    boolean :show_in_nav, :default => false, :display_name => 'Show in Navigation?'
  end
  orange do
    string :resource
    string :resource_id
    string :resource_action
    boolean :accept_args, :default => true
  end
  include DataMapper::Transaction::Resource # Make sure Transactions are included (for awesome_set)
  is :awesome_set, :scope => [:orange_site]

  def full_path
    self_and_ancestors.inject('') do |path, part| 
      if part.parent # Check if this is a child
        path = path + part.slug + '/' 
      else  # The root slug is just the initial '/'
        path = path + '/' 
      end
    end
  end

  def self.home_for_site(site_id)
    site_id = OrangeSite.get(site_id) unless site_id.is_a? OrangeSite
    root(:orange_site => site_id) 
  end


  def self.create_home_for_site(site_id, opts = {})
    opts = opts.with_defaults({:orange_site_id => site_id, :slug => '_index_', :accept_args => false, :link_text => 'Home'})
    home = self.new(opts)
    home.move(:root)
    home.save
    home
  end
end