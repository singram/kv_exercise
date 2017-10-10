require "socket"
require 'json'

class Server
  def initialize( options )
    server = TCPServer.open( options.host, options.port )
    engine = options.engine.new
    start(server, engine)
  end

  def start(server, engine)
    client_counter = 0
    loop do
      Thread.start(server.accept) do | client |
        client_handler(client, engine, client_counter+=1)
      end
    end.join
  end

  def client_handler(client, engine, id)
    puts "(#{id})      New client connection"
    loop do
      begin
        msg = client.gets
        break if msg.nil? # Client has terminated
        puts "(#{id}) Req: #{msg}"
        command = JSON.parse(msg.chomp)
        command = Hash[command.map{ |k, v| [k.to_sym, v] }]  # symbolize_keys
        next if command[:command] == 'quit' # Ignore calls for server to quit.
        result = engine.execute(command)
        response = result.nil? ? {} : { value: result }
        response = response.to_json
      rescue => e
        err = { 'error_message': e.message }.to_json
        puts "(#{id}) Err: #{err}"
        client.puts(err)
      else
        puts "(#{id}) Res: #{response}"
        client.puts response
      end
    end
    puts "(#{id})      Client disconnected"
  end

end
