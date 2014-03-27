require 'active_support/core_ext'
require 'json'
require 'webrick'
require 'rails_lite'

server = WEBrick::HTTPServer.new :Port => 8080
trap('INT') { server.shutdown }

class StatusesController < ControllerBase
  def create
    render_content(params.to_json, "text/json")
  end

  def new
  end

  def show
    render_content("status ##{params[:id]}", "text/text")
  end
end

server.mount_proc '/' do |req, res|
  router = Router.new
  router.draw do
    post Regexp.new("^/statuses$"), StatusesController, :create
    get Regexp.new("^/statuses/new$"), StatusesController, :new
  end

  route = router.run(req, res)
end

server.start
