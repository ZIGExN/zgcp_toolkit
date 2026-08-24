require 'google/cloud/logging'
require 'active_support/core_ext/module/delegation'

module ZgcpToolkit
  class Logger
    class GoogleCloudLogging
      @mutex = Mutex.new

      class << self
        def client
          @mutex.synchronize { @client ||= Google::Cloud::Logging.new }
        end

        def resource
          @mutex.synchronize { @resource ||= Google::Cloud::Logging::Middleware.build_monitored_resource }
        end
      end

      attr_reader :logger, :log_name

      delegate :debug, :info, :warn, :error, :fatal, :unknown, to: :logger

      def initialize(log_name)
        @log_name = log_name.to_s
        @logger = self.class.client.logger(@log_name, self.class.resource)
      end

      def flush!
        logger.writer.flush
      end
    end
  end
end
