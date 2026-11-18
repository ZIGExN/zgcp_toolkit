require "google/cloud/error_reporting"

module ZgcpToolkit
  # google-cloud-error_reporting (0.42.x) reads the function name of an error from the first backtrace line with
  # /`(.*)'/. Ruby 3.4 changed the line from "in `method'" to "in 'Class#method'" (a straight quote and the class name),
  # so on Ruby 3.4+ the function name is nil and Error Reporting loses it. This fills it in when the gem could not.
  module ErrorEventFunctionName
    # "path/file.rb:12:in `method'" (Ruby <= 3.3) / "path/file.rb:12:in 'Class#method'" (Ruby >= 3.4)
    BACKTRACE_LINE = /\A.+?:\d+:in [`'](?<function_name>.*)'\z/.freeze

    def from_exception(exception)
      event = super
      return event unless event.function_name.nil?

      line = exception.backtrace&.first
      match = BACKTRACE_LINE.match(line.to_s)
      event.function_name = match[:function_name] if match
      event
    end
  end
end

Google::Cloud::ErrorReporting::ErrorEvent.singleton_class.prepend(ZgcpToolkit::ErrorEventFunctionName)
