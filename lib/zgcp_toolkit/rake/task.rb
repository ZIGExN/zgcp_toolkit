module ZgcpToolkit::Rake
  module Task
    def execute(args=nil)
      task_name = self.name.gsub(':', '_')
      logger = ZgcpToolkit::Logger.new(task_name)
      args.with_defaults(logger: logger)
      super
    rescue StandardError => e
      logger.error(e, push_slack: logger.send_unexpected_error_to_slack)
      logger.flush!
    end
  end
end
