Main.stack do
  auto_reload!
  stack Orange::Middleware::Static
  stack Orange::Middleware::RouteSite, :multi => false
  stack Orange::Middleware::RouteContext
  use Rack::AbstractFormat
  
  stack Orange::Middleware::Template
  
  stack Orange::Middleware::RestfulRouter, :contexts => [:admin]
  
  load Tester.new
  load Page_Resource.new, :pages
  
  stack Orange::Middleware::Recapture
  run Main.new(orange)
end