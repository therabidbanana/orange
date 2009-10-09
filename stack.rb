Main.stack do
  stack Orange::Middleware::Static
  stack Orange::Middleware::RouteSite, :multi => false
  stack Orange::Middleware::RouteContext
  use Rack::AbstractFormat
  
  stack Orange::Middleware::RestfulRouter, :contexts => [:admin]
  run Main.new(orange)
end