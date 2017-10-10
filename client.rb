require "socket"
require 'json'

class Client
  def initialize( options )
    server = TCPSocket.open( options.host, options.port )
    start_repl(server)
  end

  def start_repl(server)
    while input = Readline.readline('> ', true) do
      exit if input == 'quit'
      server.puts( KvEngine::Base.parse(input).to_json )
      result = server.gets.chomp
      result = JSON.parse(result) unless result.nil? || result.strip == ''
      if result['error_message']
        STDERR.puts result['error_message']
      else
        puts result['value'] if result['value']
      end
    end
  end

end
