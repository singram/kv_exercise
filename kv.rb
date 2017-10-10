#!/usr/bin/ruby -w
require './options.rb'
require './repl.rb'
require './client.rb'
require './server.rb'

options = Options.parse(ARGV)

if options.mode == :repl
  Repl.run(options)
elsif options.mode == :client
  Client.new(options)
elsif options.mode == :server
  Server.new(options)
end
