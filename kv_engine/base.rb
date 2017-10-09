module KvEngine
  class Base

    ENGINE_VERSION = 'Base 0.0'

    def initialize
      raise "Engine not implemented"
    end

    # READ <key> Reads and prints, to stdout, the val associated with key. If the value is not present an error is printed to stderr.
    def read(key:)
      raise "READ function not implemented"
    end

    # WRITE <key> <val> Stores val in key.
    def write(key:, value:)
      raise "WRITE function not implemented"
    end

    # DELETE <key> Removes all key from store. Future READ commands on that key will return an error.
    def delete(key:)
      raise "DELETE function not implemented"
    end

    # START Start a transaction.
    def start
      raise "START function not implemented"
    end

    # COMMIT Commit a transaction. All actions in the current transaction are committed to the parent transaction or the root store.
    #        If there is no current transaction an error is output to stderr.
    def commit
      raise "COMMIT function not implemented"
    end

    def version
      self.class::ENGINE_VERSION
    end

    # ABORT Abort a transaction. All actions in the current transaction are discarded.
    def abort
      raise "ABORT function not implemented"
    end

    def quit
      exit
    end

    def help
      <<-EOS

Supported commands are;
  READ    <key>       Reads and prints, to stdout, the val associated with key. If the value is not present an error is printed to stderr.
  WRITE   <key> <val> Stores val in key.
  DELETE  <key>       Removes all key from store. Future READ commands on that key will return an error.
  START               Start a transaction.
  COMMIT              Commit a transaction. All actions in the current transaction are committed to the parent transaction or the root store.
                      If there is no current transaction an error is output to stderr.
  ABORT               Abort a transaction. All actions in the current transaction are discarded.
  VERSION             Engine version
  HELP                List all available commands
  QUIT                Exit the REPL cleanly. A message to stderr may be output.

EOS
    end

    def execute(input)
      params = parse(input)
      if params[:params].empty?
        self.send(params[:cmd])
      else
        self.send(params[:cmd], **params[:params])
      end
    end

    private

    def parse(input)
      parts = input.split(' ').map(&:strip).reject(&:empty?)
      params = { cmd: parts.shift.downcase, params: {} }
      params[:params][:key]   = parts.shift if parts[0]
      params[:params][:value] = parts.join(' ') if parts[0]
      params
    end

    def transaction_count
      raise "Transaction count function not implemented"
    end

  end

end
