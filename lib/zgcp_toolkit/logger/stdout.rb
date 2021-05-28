require 'logger'

module ZgcpToolkit
  class Logger 
    class Stdout
      attr_reader :logger, :log_name

      def initialize(log_name)
        @log_name = log_name.to_s
        @logger  = ::Logger.new(STDOUT)
      end

      [:debug, :info, :warn, :error, :fatal, :unknown].each do |log_level_method|
        define_method(log_level_method) do |log|
          logger.send(log_level_method, "#{log_name} -- #{log}")
        end
      end

      def flush!
        # no-op
      end
    end
  end
end
