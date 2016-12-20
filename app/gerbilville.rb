require 'rack'
require_relative '../lib/frames/router'
require_relative '../lib/frames/exceptions'
require_relative '../lib/frames/static_assets'
require_relative 'controllers/gerbils_controller'

router = Router.new
router.draw do
  get Regexp.new("^/gerbils/new$"), GerbilsController, :new
  post Regexp.new("^/gerbils$"), GerbilsController, :create
  get Regexp.new("^/gerbils/(?<gerbil_id>\\d+)$"), GerbilsController, :show
  delete Regexp.new("^/gerbils/(?<gerbil_id>\\d+)$"),
         GerbilsController, :destroy
  get Regexp.new("^/$"), GerbilsController, :index
end

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req, res)
  res.finish
end

app = Rack::Builder.new do
  use StaticAssets
  use Exceptions
  run app
end.to_app

Rack::Server.start(
  app: app,
  Port: 3000
)
