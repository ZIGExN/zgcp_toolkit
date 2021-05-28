module ZgcpToolkit
  class Logger
    class GoogleCloudLogging
      attr_reader :logger, :log_name

      delegate :debug, :info, :warn, :error, :fatal, :unknown, to: :logger

      def initialize(log_name)
        @log_name = log_name.to_s
        logging  = Google::Cloud::Logging.new
        resource = Google::Cloud::Logging::Middleware.build_monitored_resource
        @logger  = logging.logger @log_name, resource
      end

      def flush!
        logger.writer.async_stop!
      end
    end
  end
end
