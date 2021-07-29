# GCP Toolkit
Manage integration between Rails & Google Cloud services.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stackdriver' # Stackdriver gem auto installs middlewares to catch errors if you are running a Rails app.
gem 'zgcp_toolkit'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install zgcp_toolkit

Next, you need to run the generator:

    $ rails generate zgcp_toolkit

## Logger

Unexpected errors in rake tasks are caught automatically & write to a log file in Cloud Logging. And, by default, when GCP Toolkit caught an unexpected error, it push a key & value (key: `push_slack` with value: `true`) in Cloud Logging Log `jsonPayload` so that the log that should be sent on Slack can be filtered.

### Usage

```ruby
namespace :tcv_transactions do
  task :daily_import
    ZgcpToolkit::Logger.create(:log_name) do |logger|
      logger.info("Heyyyyyy!") # You can log anything to console, also google cloud logging
      Bug.last
    end
  end
end
```

```ruby
logger = ZgcpToolkit::Logger.new(:log_name)
logger.info("Heyyyyyy!")
logger.error(message: "Heyyyyy!", backtrace: ["line-1", "line-2"])
logger.error(message: "Hello Bug !!", backtrace: ["line-1", "line-2"])
logger.warn("Hey hey nyc!")
```

### Controller

You can send controller errors to Google Cloud Loggings

```ruby
# app/controllers/application_controller.rb

rescue_from StandardError do |e|
  raise e if Rails.env.development?

  # Useful ENV information will also be sent along with the error
  ZgcpToolkit::Logger.report_error_request(e, request)

  head :internal_server_error
end

```

### Note on using Pub/Sub and Cloud Function to deliver log to your Slack channel

- Function invocations are charged at a flat rate regardless of the source of the invocation. This includes HTTP function invocations from HTTP requests, events forwarded to background or CloudEvent functions, and invocations resulting from the call API.

- When GCP filter log to sink to Cloud Pub/Sub topic it will use CloudEvent event function so that will also count as an invocation.

- When logging from the rails app, you should log error levels or higher to reduce costs.

- For sending a Slack notification when a training task gets completed, a possible solution might be setting up a Pub/Sub sink for matching logs from Cloud Logging to be sent to. Details here in Exporting logs with the Google Cloud Console. If a log matches the sink’s query (look for all training status updates from AI Platform), then Cloud Logging will send the log directly to the indicated Pub/Sub topic and extra VM is not needed for this.

- After sending the messages to a Pub/Sub topic, you can set up a Cloud Function to post messages to Slack (and/or to email you) when the logs indicate that the AI Platform training job is done. Please note that the Cloud Function will only run when a relevant log is posted to Pub/Sub.Details on Google Cloud Pub/Sub Triggers and Configuring Slack notifications.

### References
- https://cloud.google.com/functions/docs/calling/pubsub
- https://cloud.google.com/logging/docs/export/configure_export_v2
- https://cloud.google.com/cloud-build/docs/configure-third-party-notifications#slack_notifications
