Main.stack do
  stack Orange::Middleware::Static
  stack Orange::Middleware::RouteSite, :multi => false
  stack Orange::Middleware::RouteContext

  use Rack::AbstractFormat
  run Main.new
end