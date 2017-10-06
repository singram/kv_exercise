# Naive implementation that copies entire data frame between transactions using a stack model.
# Memory and cost to start transactions will increase with size of data stored. ( n copies / time to copy )
# Rollback, reads, writes and deletes should be O(1) performance.
class KvEngine::Stack < KvEngine::Base

    ENGINE_VERSION = 'Data set stack 1.0.0'

    def initialize
      puts "Initalizing #{self.class::ENGINE_VERSION}..."
      @stack = [{}]
      self.start
      nil
    end

    def start
      @stack << current_frame.dup
      nil
    end

    def abort
      @stack.pop
      nil
    end

    def commit
      raise Exceptions::NoOpenTransaction.new if @stack.size < 2
      commit_frame = @stack.pop
      @stack.pop
      @stack.push commit_frame
      nil
    end

    def read(key:)
      raise Exceptions::UnknownKey.new unless current_frame.has_key?(key)
      current_frame[key]
    end

    def write(key:, value:)
      current_frame[key] = value
      nil
    end

    def delete(key:)
      current_frame.delete key
      nil
    end

    private

    def current_frame
      @stack[-1]
    end

end
