if Rails.env.development? || Rails.env.test?
  loggers = [:std_out]
else
  loggers = [:google_cloud_logging]
end

ZgcpToolkit::Logger.config.registered_loggers = loggers
