if Rails.env.development?
  loggers = [:std_out]
else
  loggers = [:google_cloud_logging]
end

ZgcpToolkit::Logger.config.registered_loggers = loggers
