require "singleton"

module OpengraphTransporter
  
  class GracefulQuit
    include Singleton

    attr_accessor :breaker

    def initialize
      self.breaker = false
    end

    class << self

      def enable
        trap('INT') {
          yield if block_given?
          self.instance.breaker = true
        }
      end

      def check(message = "Quitting Exporter")
        if self.instance.breaker
          yield if block_given?
          puts message
          exit
        end
      end

    end

  end
end