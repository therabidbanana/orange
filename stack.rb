Main.stack do
  auto_reload!
  use_exceptions
  stack Orange::Middleware::Globals
  prerouting :multi => false
  use Rack::AbstractFormat
  
  stack Orange::Middleware::Template
  
  stack Orange::Middleware::RestfulRouter, :contexts => [:admin]
  stack Orange::Middleware::Database
  load Tester.new
  load Page_Resource.new, :pages
  
  run Main.new(orange)
end