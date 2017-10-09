#!/usr/bin/ruby -w
require './options.rb'
require './repl.rb'

options = Options.parse(ARGV)

if options.mode == 'repl'
  Repl.run(options)
elsif options.mode == 'client'
  raise 'Client unimplemented'
elsif options.mode == 'server'
  raise 'Server unimplemented'
end
