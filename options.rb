require 'optparse'
require 'ostruct'
require './kv_engine/stack.rb'
require './kv_engine/field_stack.rb'

class Options

  ENGINES = { stack: KvEngine::Stack, field_stack: KvEngine::FieldStack }.freeze
  MODES = [ :client, :server, :repl ].freeze

  def self.parse(input)
    options = OpenStruct.new
    options.engine = KvEngine::FieldStack
    options.mode = 'repl'
    options.host = 'localhost'
    options.port = 3000

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: kv_repl.rb [options]"

      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-e", "--engine [ENGINE]", ENGINES.keys,
              "Select engine (stack, field_stack) (default: #{ENGINES.key(options.engine)} )") do |e|
                options.engine = ENGINES[e]
              end
      opts.on("-m", "--mode [MODE]", MODES,
              "Select run mode (client, server, repl) (default: #{options.mode})") do |m|
                options.mode = m
              end
      opts.on("-h", "--host [HOST]",
              "Select host to connect to (default: #{options.host}})") do |h|
                options.host = h
              end
      opts.on("-p", "--port [PORT]",
              "Select port to connect to/ run at (default: #{options.port})") do |h|
                options.host = h
              end
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end
    opt_parser.parse!(input)
    options
  end

end
