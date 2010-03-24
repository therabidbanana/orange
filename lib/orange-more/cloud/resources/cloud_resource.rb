require 'rest_client'

module Orange
  class CloudResource < Orange::Resource
    ORANGE_PING_KEY = "c99550a0430eb9054eb4b7ee290664cf"
    call_me :cloud
    def stack_init
      options[:ping_fm_key] = orange.options['ping_fm_key'] || false
    end
    
    def microblog(packet, status, opts = {})
      params = {    :api_key => ORANGE_PING_KEY, 
                    :user_app_key => options[:ping_fm_key], 
                    :post_method => "microblog",
                    :body => status}.merge(opts)
      # Thread.new {
      xml_result = RestClient.post("http://api.ping.fm/v1/user.post", params) if params[:user_app_key]
    end
  end
end