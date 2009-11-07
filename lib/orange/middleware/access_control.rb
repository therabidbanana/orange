require 'orange/middleware/base'



module Orange::Middleware
  
  class AccessControl < Base
    def init(*args)
      defs = {:locked => [:admin, :orange], :login => '/login', 
              :handle_login => true, :openid => true, :config_id => true}
      opts = args.extract_with_defaults(defs)
      @openid = opts.has_key?(:openid) ? opts[:openid] : false
      @locked = opts[:locked]
      @login = opts[:login]
      @handle = opts[:handle_login]
      @single = opts[:config_id]
    end
      
    def packet_call(packet)
      packet['user.id'] ||= (packet.session['user.id'] || false)
      if @openid && need_to_handle?(packet)
        ret = handle_openid(packet)
        return ret if ret # unless handle_openid returns false, exit immediately
      end
      unless access_allowed?(packet)
        packet.session['user.after_login'] = packet.request.path
        packet.reroute(@login)
      end
      after = packet.session.has_key?('user.after_login') ?
                  packet.session['user.after_login'] : false
      packet.session['user.after_login'] = false
      
      # Save id into session if we have one.
      packet.session['user.id'] = packet['user.id']
      
      # If the user was supposed to be going somewhere, redirect there
      packet.reroute(after) if after && packet['user.id'] && need_to_handle?(packet)
      pass packet
    end
    def access_allowed?(packet)
      return true unless @locked.include?(packet['route.context'])
      if packet['user.id']
        if @single && (packet['user.id'] == packet['orange.globals']['main_user'])
          true
        elsif @single
          # Current id no good. 
          packet['user.id'] = false
          packet.session['user.id'] = false
          false
        else
          true
        end
      else
        false
      end
    end
    
    def need_to_handle?(packet)
      @handle && (packet.env['REQUEST_PATH'] == @login)
    end
    
    def handle_openid(packet)
      packet.reroute('/') if packet['user.id'] # Reroute to index if we're logged in.
      # If login set
      if packet.request.post?
        # Check for openid response
        if resp = packet.env["rack.openid.response"]
          if resp.status == :success
            packet['user.id'] = resp.identity_url
            packet['user.openid.url'] = resp.identity_url
            packet['user.openid.response'] = resp
            false
          else
            packet.session['flash.error'] = resp.status
            packet.reroute(@login)
            false
          end
        # Set WWW-Authenticate header if awaiting openid.response
        else
          packet[:status] = 401
          packet[:headers] = {}
          packet.add_header('WWW-Authenticate', Rack::OpenID.build_header(
                :identifier => packet.request.params["openid_identifier"]
              ))
          packet[:content] = 'Got openID?'
          packet.finish
        end
      # Show login form, if necessary
      else
        packet[:content] = orange[:parser].haml('openid_login.haml', packet)
        packet.finish
      end
    end # end handle_openid
  end
end