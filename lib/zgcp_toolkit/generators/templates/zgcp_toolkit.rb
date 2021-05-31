require 'dry/configurable'
require 'google/cloud/logging'
require 'rake/task'

Rake::Task.prepend(ZgcpToolkit::Rake::Task)

loggers = [:std_out]

loggers.push(:google_cloud_logging) unless Rails.env.development?

ZgcpToolkit::Logger.config.registered_loggers = loggers
