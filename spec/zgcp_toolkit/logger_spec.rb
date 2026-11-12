require 'dry/configurable/test_interface'

RSpec.describe ZgcpToolkit::Logger do
  before { described_class.enable_test_interface }
  after { described_class.reset_config }

  describe '.registered_loggers' do
    it 'defaults to the stdout and Google Cloud Logging loggers' do
      expect(described_class.registered_loggers).to eq(
        [ZgcpToolkit::Logger::Stdout, ZgcpToolkit::Logger::GoogleCloudLogging]
      )
    end

    it 'maps the logger names set through config to their classes' do
      described_class.config.registered_loggers = [:std_out]

      expect(described_class.registered_loggers).to eq([ZgcpToolkit::Logger::Stdout])
      expect(described_class.config.registered_loggers).to eq([ZgcpToolkit::Logger::Stdout])
    end
  end

  describe '.create' do
    it 'builds one logger per registered logger' do
      described_class.config.registered_loggers = [:std_out]

      logger = described_class.create(:spec_log)

      expect(logger.log_name).to eq('spec_log')
      expect(logger.loggers.map(&:class)).to eq([ZgcpToolkit::Logger::Stdout])
    end
  end
end
