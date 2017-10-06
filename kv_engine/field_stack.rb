# KV implementation that maintains a stack per field with a field list per transaction.
# Memory and cost increase with transaction depth but significantly more efficent than KVEngine::Stack
# Abort & commit is O(n) where n is number of fields,
# Reads, writes and deletes should be O(1) performance.
require 'pp'

class KvEngine::FieldStack < KvEngine::Base

  ENGINE_VERSION = 'Field stack 1.0.0'
  DELETED = :deleted

  def initialize
    puts "Initalizing #{self.class::ENGINE_VERSION}..."
    @mutex = Mutex.new
    @data = {}
    @transactions = []
    self.start
    nil
  end

  def introspect
    pp @data
    pp @transactions
  end

  def start
    @mutex.synchronize do
      @transactions << []
    end
    nil
  end

  def abort
    @mutex.synchronize do
      unless @transactions.empty?
        fields_to_undo = @transactions.pop
        fields_to_undo.each do |field|
          @data[field].pop
          @data.delete(field) if @data[field].empty?
        end
      end
    end
    nil
  end

  def commit
    raise Exceptions::NoOpenTransaction.new if @transactions.empty?
    @mutex.synchronize do
      fields_to_commit = @transactions.pop
      fields_to_commit.each do |field|
        value_to_commit = @data[field].pop
        @data[field].pop # Value to discard
        @data[field].push(value_to_commit)
      end
    end
    nil
  end

  def read(key:)
    raise Exceptions::UnknownKey.new unless @data.has_key?(key) || @data[key][-1] == DELETED
    @mutex.synchronize do
      @data[key][-1]
    end
  end

  def write(key:, value:)
    @mutex.synchronize do
      write_raw(key: key, value: value)
    end
    nil
  end

  def delete(key:)
    @mutex.synchronize do
      write_raw(key: key, value: DELETED) if @data.has_key?(key)
    end
    nil
  end

  private

  def write_raw(key:, value:)
    if @data.has_key?(key)
      if @transactions[-1].include?(key)
        @data[key][-1] = value
      else
        @data[key] << value
        @transactions[-1] << key
      end
    else
      @data[key] = [value]
      @transactions[-1] << key
    end
    @transactions[-1].uniq!
    nil
  end

end
