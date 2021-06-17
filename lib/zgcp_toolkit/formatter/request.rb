module ZgcpToolkit::Formatter
  class Request
    FILTERED_ENV_LIST = %w(action_dispatch.remote_ip QUERY_STRING PATH_INFO CONTENT_LENGTH ORIGINAL_FULLPATH HTTP_X_FORWARDED_FOR
                           HTTP_X_FORWARDED_PROTO HTTP_USER_AGENT HTTP_HOST HTTP_ORIGIN HTTP_REFERERHTTP_SEC_CH_UA HTTP_SEC_CH_UA_MOBILE
                           HTTP_ACCEPT TTP_ACCEPT_ENCODING HTTP_ACCEPT_LANGUAGE HTTP_CACHE_CONTROL SERVER_PROTOCOL
                           SERVER_PORT SERVER_NAME SERVER_SOFTWARE REQUEST_URI REQUEST_METHOD REMOTE_ADDR warden).freeze
    def call(request)
      log_object = {}
      log_object[:request]     = request_filter(request)
      log_object[:session]     = session_filter(request)
      log_object[:environment] = environment_filter(request)
      log_object
    end

    def format_for_report(request)
      log_object = {}
      log_object[:request]     = beauty_format request_filter(request)
      log_object[:session]     = beauty_format session_filter(request)
      log_object[:environment] = beauty_format separation_environment_filter(request)

      result = log_object.map { |key, value| "#{key.capitalize}:\n#{value}\n" }
      result.join("\n")
    end

    private

    attr_accessor :request

    def beauty_format(data)
      data.map { |k,v| "#{k.to_s.indent(4)}: #{v}" }.join("\n")
    end

    def environment_filter(request)
      result = {}
      request.filtered_env.keys.each do |key|
        result[key] = request.filtered_env[key]
      end
      result
    end

    def separation_environment_filter(request)
      result = {}
      FILTERED_ENV_LIST.each do |key|
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
