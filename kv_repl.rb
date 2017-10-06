require 'readline'
require './kv_engine/base.rb'
require './kv_engine/exceptions.rb'
require './kv_engine/stack.rb'
require './kv_engine/field_stack.rb'

bnd = binding
eng = KvEngine::FieldStack.new
while input = Readline.readline('> ', true) do
  begin
    result = eng.execute(input)
  rescue NoMethodError => e
    STDERR.puts "\e[31m#{e.message}\e[0m"
    puts eng.help
  rescue Exceptions::KVEngineError => e
    STDERR.puts e.message
  rescue => e
    STDERR.puts "\e[31m#{e.class}\e[0m - #{e.message}"
  else
    puts result if result
  end
end
