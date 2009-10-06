module Orange
  class ModelResource < RoutableResource
    
    def self.use(model_class)
      @@model_class = model_class
    end
    
    def view(packet, *args)
      opts = args.extract_options!.with_defaults({:mode => :show, :path => ''})
      props = @@model_class.form_props(packet[:context])
      
      resource_id = opts[:id] || packet[:resource_id] || false      
      
      haml_opts = {:props => props, :resource => self.class.to_s, :view_opts => opts}
      case opts[:mode]
      when :show
        haml_opts.with_defaults! :resource => findOne(packet, opts[:mode], resource_id)
        orange[:parser].haml('show.haml', packet, haml_opts)
      when :edit
        haml_opts.with_defaults! :resource => findOne(packet, opts[:mode], resource_id)
        orange[:parser].haml('edit.haml', packet, haml_opts)
      when :create
        haml_opts.with_defaults! :resource => findOne(packet, opts[:mode], resource_id)
        orange[:parser].haml('create.haml', packet, haml_opts)
      when :table_row
        haml_opts.with_defaults! :resource => findOne(packet, opts[:mode], resource_id)
        orange[:parser].haml('table_row.haml', packet, haml_opts)
      when :list
        haml_opts.with_defaults! :resource => findList(packet, opts[:mode])
        orange[:parser].haml('list.haml', packet, haml_opts)
      else
        'other'
      end
    end
    
    def findOne(packet, mode, id = false)
      return false unless id
      @@model_class.get(id) 
    end
    
    def findList(packet, mode)
      @@model_class.all
    end
    
    def viewExtras(packet, mode)
      {}
    end
    
    def route(path, packet)
      parts = path.split('/')
      if parts[0] =~ /^[0-9]+$/
        route_id = parts.shift 
      else 
        route_id = false
      end
      parts.unshift('show') if parts.empty? && route_id
      new_path = parts.join('/')
      packet[:resource_id] = route_id if route_id
      super(new_path, packet)
    end
    
    def show(path, packet); view packet, :path => path, :mode => :show; end
    
    def edit(path, packet); view packet, :path => path, :mode => :edit; end
    
    def create(path, packet); view packet, :path => path, :mode => :create; end
    
    def table_row(path, packet); view packet, :path => path, :mode => :table_row; end
    
    def list(path, packet); view packet, :path => path, :mode => :list; end
    
    def index(path, packet); view packet, :path => path, :mode => :list; end
  
  end
end