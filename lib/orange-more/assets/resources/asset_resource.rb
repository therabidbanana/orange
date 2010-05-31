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
        "foo"
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
    
    def onDelete(packet, m, opts = {})
      begin
        FileUtils.rm(orange.app_dir('assets','uploaded', m.path)) if m.path
        FileUtils.rm(orange.app_dir('assets','uploaded', m.secondary_path)) if m.secondary_path
      rescue
        # Problem deleting file
      end
      m.destroy if m
    end
    
    def asset_html(packet, id)
      m = model_class.get(id)
      m ? m.to_asset_tag : false
    end
  end
end