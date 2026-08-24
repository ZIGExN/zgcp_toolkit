require 'spec_helper'

RSpec.describe ZgcpToolkit::Logger::GoogleCloudLogging do
  before { described_class.instance_variable_set(:@client, nil) }

  it 'builds the underlying Google::Cloud::Logging client only once' do
    fake_project = instance_double(
      Google::Cloud::Logging::Project,
      logger: instance_double(Google::Cloud::Logging::Logger)
    )
    allow(Google::Cloud::Logging).to receive(:new).and_return(fake_project)
    allow(Google::Cloud::Logging::Middleware).to receive(:build_monitored_resource)

    3.times { |n| described_class.new("log_#{n}") }

    expect(Google::Cloud::Logging).to have_received(:new).once
  end
end
