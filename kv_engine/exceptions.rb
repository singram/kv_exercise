module Exceptions

  class KVEngineError < StandardError
  end

  class UnknownKey < KVEngineError
    def initialize
      super("Key not found")
    end
  end

  class NoOpenTransaction < KVEngineError
    def initialize
      super("No open transaction")
    end
  end

end
