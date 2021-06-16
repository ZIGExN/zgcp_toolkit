module ZgcpToolkit::Formatter
  class Request
    def call(request)
      log_object = {}
      log_object[:request]     = request_filter(request)
      log_object[:session]     = session_filter(request)
      log_object[:environment] = environment_filter(request)
      log_object
    end

    private

    attr_accessor :request

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
      result[:timestamp]      = Time.current
      result[:server]         = Socket.gethostname
      result[:process]        = $$
      if defined?(Rails) && Rails.respond_to?(:root)
        result[:rails_root] = Rails.root
      end
      result
    end
  end
end
