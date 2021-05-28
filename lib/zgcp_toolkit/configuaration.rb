require 'dry/configurable'

module ZgcpToolkit
  class Configuaration
    extend Dry::Configurable

    AVAILABLE_LOGGERS = {
      std_out: ZgcpToolkit::Logger::Stdout,
      google_cloud_logging: ZgcpToolkit::Logger::GoogleCloudLogging
    }

    setting :registered_loggers, [:std_out, :google_cloud_logging], reader: true do |logger_names|
      logger_names.map { |n| AVAILABLE_LOGGERS[n] }
    end
  end
end
