require 'fileutils'
module Orange
  class AssetResource < Orange::ModelResource
    use Orange::Asset
    call_me :assets
    def afterLoad
      orange[:admin, true].add_link("Content", :resource => @my_orange_name, :text => 'Assets')
      orange.register(:stack_loaded) do
        orange[:radius].context.define_tag "asset" do |tag|
          if tag.attr['id']
            (m = model_class.first(:id => tag.attr['id'])) ? m.to_asset_tag : 'Invalid Asset'
          else
            ''
          end
        end
      end
    end
    
    def new(packet, *opts)
      if packet.request.post?
        params = packet.request.params[@my_orange_name.to_s]
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
          
          model_class.new(params).save
        end
      end
      packet.reroute(@my_orange_name, :orange)
    end
    
    def delete(packet, *opts)
      if packet.request.delete?
        m = model_class.get(packet['route.resource_id'])
        begin
          FileUtils.rm(orange.app_dir('assets','uploaded', m.path)) if m.path
          FileUtils.rm(orange.app_dir('assets','uploaded', m.secondary_path)) if m.secondary_path
        rescue
          # Problem deleting file
        end
        m.destroy if m
      end
      packet.reroute(@my_orange_name, :orange)
    end
  end
end