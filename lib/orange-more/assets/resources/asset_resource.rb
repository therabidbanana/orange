require 'fileutils'
module Orange
  class Orange::Carton
    # Define a helper for input type="text" type database stuff
    # Show in a context if wrapped in one of the helpers
    def self.asset(name, opts = {})
      add_scaffold(name, :asset, Integer, opts)
    end
  end
  
  class AssetResource < Orange::ModelResource
    use OrangeAsset
    call_me :assets
    
    def stack_init
      orange[:admin, true].add_link("Content", :resource => @my_orange_name, :text => 'Assets')
      orange[:radius, true].define_tag "asset" do |tag|
        if tag.attr['id']
          (m = model_class.first(:id => tag.attr['id'])) ? m.to_asset_tag : 'Invalid Asset'
        else
          ''
        end
      end
      orange[:scaffold].add_scaffold_type(:asset) do |name, val, opts|
        if opts[:show]
          opts[:model].to_asset_tag
        else
          packet = opts[:packet]
          
          asset_html = val ? orange[:assets].asset_html(packet, val) : ""
          ret = "<input type=\"hidden\" value=\"#{val}\" name=\"#{opts[:model_name]}[#{name}]\" />"
          if val.blank?
            ret += "<span class='asset_preview'></span><a class='insert_asset' rel=\"#{opts[:model_name]}[#{name}]\" href='/admin/assets/insert'>Insert Asset</a>"
          else
            ret += "<span class='asset_preview'>#{asset_html}</span><a class='insert_asset' rel=\"#{opts[:model_name]}[#{name}]\" href='/admin/assets/#{val}/change'>Change Asset</a>"
          end
          ret = "<label for=''>#{opts[:display_name]}</label><br />" + ret if opts[:label]
        end
      end
    end
    
    def onNew(packet, params = {})
      m = false
      if(file = params['file'][:tempfile])
        file_path = orange.app_dir('assets','uploaded', params['file'][:filename]) if params['file'][:filename]
        # Check for secondary file (useful for videos/images with thumbnails)
        if(params['file2'] && secondary = params['file2'][:tempfile])
          secondary_path = orange.app_dir('assets','uploaded', params['file2'][:filename])
        else
          secondary_path = nil
        end
        # Move the files
        FileUtils.cp(file.path, file_path)
        FileUtils.cp(secondary.path, secondary_path) if secondary_path
        
        params['path'] = params['file'][:filename] if file_path
        params['secondary_path'] = params['file2'][:filename] if secondary_path
        params['mime_type'] = params['file'][:type] if file_path
        params['secondary_mime_type'] = params['file2'][:type] if secondary_path
        params.delete('file')
        params.delete('file2')
        
        m = model_class.new(params)
      end
      m
    end
    
    # Creates a new model object and saves it (if a post), then reroutes to the main page
    # @param [Orange::Packet] packet the packet being routed
    def new(packet, opts = {})
      no_reroute = opts.delete(:no_reroute) 
      xhr = packet.request.xhr? || packet.request.params["fake_xhr"]
      if packet.request.post? || !opts.blank?
        params = opts.with_defaults(opts.delete(:params) || packet.request.params[@my_orange_name.to_s] || {})
        before = beforeNew(packet, params)
        obj = onNew(packet, params) if before
        afterNew(packet, obj, params) if before
        obj.save if obj && before
      end
      packet.reroute(@my_orange_name, :orange) unless (xhr || no_reroute)
      packet['template.disable'] = true if xhr
      (xhr ? obj.to_s : obj) || false
    end
    
    def insert(packet, opts = {})
      do_view(packet, :insert, opts)
    end
    
    def change(packet, opts = {})
      do_view(packet, :change, opts)
    end
    
    def find_extras(packet, mode, opts = {})
      {:list => model_class.all}
    end
    
    def onDelete(packet, m, opts = {})
      begin
        FileUtils.rm(orange.app_dir('assets','uploaded', m.path)) if m.path
        FileUtils.rm(orange.app_dir('assets','uploaded', m.secondary_path)) if m.secondary_path
      rescue
        # Problem deleting file
      end
      m.destroy if m
    end
    
    def asset_html(packet, id = false)
      id ||= packet['route.resource_id']
      m = model_class.get(id)
      m ? m.to_asset_tag : false
    end
  end
end