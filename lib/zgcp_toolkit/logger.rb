require 'dry/configurable'
require 'zgcp_toolkit/logger/stdout'
require 'zgcp_toolkit/logger/google_cloud_logging'

module ZgcpToolkit
  class Logger
    extend Dry::Configurable

    REGEX_VALID_NAME = /^[a-z0-9_]+$/.freeze

    AVAILABLE_LOGGERS = {
      std_out: ZgcpToolkit::Logger::Stdout,
      google_cloud_logging: ZgcpToolkit::Logger::GoogleCloudLogging
    }

    setting :registered_loggers, [:std_out, :google_cloud_logging], reader: true do |logger_names|
      logger_names.map { |n| AVAILABLE_LOGGERS[n] }
    end

    class Error < StandardError; end
    class UnsupportedLogType < Error; end
    class InvalidLogName < Error; end

    class << self
      def create(log_name)
        raise InvalidLogName, "Log name is invalid. Log name regex is #{REGEX_VALID_NAME.inspect}" unless valid_name?(log_name.to_s)

        logger = Logger.new(log_name.to_s)

        begin
          yield(logger) if block_given?
        rescue StandardError => e
          logger.error(e, push_slack: logger.send_unexpected_error_to_slack)
          logger.flush!
        end

        logger
      end

      def report_error_request(error, request)
        message = ZgcpToolkit::Formatter::Request.new.format_for_report(request)

        Google::Cloud::ErrorReporting.report error do |event|
          event.message = event.message + '\n\n' + message
        end
      end
  
      private

      def valid_name?(log_name)
        return true if log_name.match(REGEX_VALID_NAME)
        false
      end
    end

    DEFAULT_BACKTRACE_LIMIT = 10

    attr_accessor :send_unexpected_error_to_slack, :backtrace_limit
    attr_reader :loggers, :log_name

    def initialize(log_name)
      @log_name = log_name
      @send_unexpected_error_to_slack = true
      @backtrace_limit = DEFAULT_BACKTRACE_LIMIT
      @loggers = ZgcpToolkit::Logger.registered_loggers.map { |logger| logger.new(log_name) }
    end

    [:debug, :info, :warn, :error, :fatal, :unknown].each do |log_level_method|
      define_method(log_level_method) do |log, push_slack: false|
        log_object =
          case log
          when StandardError
            obj = { message: log.message, backtrace: log.backtrace.first(backtrace_limit) }
            obj.merge!(push_slack: true) if push_slack
            obj
          when Hash
            log
          when String
            obj = { message: log }
            obj.merge!(push_slack: true) if push_slack
            obj
          else
            raise UnsupportedLogType, "#{log.class.name} is not supported!"
          end
        loggers.each { |a| a.send(log_level_method, log_object) }
      end
    end

    def error_request(error, request, **args)
      filter_request_params = ZgcpToolkit::Formatter::Request.new.call(request)

      error({ message: error.message, backtrace: error.backtrace.first(backtrace_limit) }.merge!(filter_request_params).merge!(args))
    end

    def flush!
      loggers.each { |a| a.flush! }
    end
  end
end
