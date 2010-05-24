require 'orange-core/middleware/base'

module Orange::Middleware
  class Analytics < Base
    
    # Passes packet then parses the return
    def packet_call(packet)
      pass packet
      ga_key = orange.options['google_analytics_key'] || false
      if packet['route.context'] == :live && ga_key
          ga = "<script type=\"text/javascript\">

            var _gaq = _gaq || [];
            _gaq.push(['_setAccount', '"+ga_key+"']);
            _gaq.push(['_trackPageview']);

            (function() {
              var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
              ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
              var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
            })();

          </script>"
          packet[:content] = packet[:content].sub(/.*<\/body>$/, ga + '</body>')
      end
      packet.finish
    end
    
  end
end