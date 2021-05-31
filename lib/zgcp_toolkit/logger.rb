require 'dry/configurable'
require 'zgcp_toolkit/logger/stdout'
require 'zgcp_toolkit/logger/google_cloud_logging'

module ZgcpToolkit
  class Logger
    extend Dry::Configurable

    AVAILABLE_LOGGERS = {
      std_out: ZgcpToolkit::Logger::Stdout,
      google_cloud_logging: ZgcpToolkit::Logger::GoogleCloudLogging
    }

    setting :registered_loggers, [:std_out, :google_cloud_logging], reader: true do |logger_names|
      logger_names.map { |n| AVAILABLE_LOGGERS[n] }
    end

    class Error < StandardError; end
    class UnsupportedLogType < Error; end

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

    def error_request(error, **args)
      env = args.fetch(:env)
      args.delete(:env)
      formatted_env = format_env(env)

      error({message: error.message, backtrace: error.backtrace.first(backtrace_limit)}.merge!(formatted_env))
    end

    def flush!
      loggers.each { |a| a.flush! }
    end

    private

    def format_env(request)
      log_object = {}
      log_object[:request]     = request_filter(request)
      log_object[:session]     = session_filter(request)
      log_object[:environment] = environment_filter(request)
      log_object
    end

    def environment_filter(request)
      result = {}
      request.filtered_env.keys.each do |key|
        result[key] = request.filtered_env[key]
      end
      result
    end

    def session_filter(request)
      result = {}
      result[:session_id]   = request.ssl? ? "[FILTERED]" : request.session['session_id'] || request.env['rack.session.options'][:id].inspect
      result[:data_session] = request.session.to_hash
      result
    end

    def request_filter(request)
      result = {}
      result[:url]            = request.url
      result[:request_method] = request.request_method
      result[:ip_address]     = request.remote_ip
      result[:parameters]     = request.filtered_parameters.inspect
      result[:timestamp]      = @timestamp
      result[:server]         = Socket.gethostname
      result[:process]        = $$
      if defined?(Rails) && Rails.respond_to?(:root)
        result[:rails_root] = Rails.root
      end
      result
    end
  end
end
