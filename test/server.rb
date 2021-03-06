require 'active_support/core_ext'
require 'webrick'
require 'rails_lite'

server = WEBrick::HTTPServer.new :Port => 8080
trap('INT') { server.shutdown }

class MyController < ControllerBase
  def go
    render_content("hello world!", "text/html")

   session["count"] ||= 0
   session["count"] += 1
   render_content("#{session["count"]}", "text/html")
   
   render :show
  end
end

server.mount_proc '/' do |req, res|
  MyController.new(req, res).go
end

server.start
