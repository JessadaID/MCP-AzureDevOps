# azure_devops/api_client.rb
module AzureDevops
  class ApiClient
    require "net/http"
    require "json"
    require "base64"
    require "uri"

    # --- Configuration ---
    # Using .env for configuration temporarily.
    # In the future, we plan to implement Microsoft 365 login for authentication.
    # When Microsoft 365 login is enabled, we will replace ENV.fetch with a session-based approach
    # or database lookup (e.g., current_user.oauth_token or session[:access_token]).
    def self.organization
      ENV.fetch("AZURE_DEVOPS_ORGANIZATION", "") # for testing
    end

    def self.pat
      ENV.fetch("AZURE_DEVOPS_PAT", "") # for testing
    end
    
    # --- Helper Methods ---

    def self.encode_path(str)
      URI.encode_www_form_component(str).gsub("+", "%20")
    end
    
    # --- Response Handlers ---

    def self.success_response(text)
      # Assuming MCP::Tool::Response is defined or available
      MCP::Tool::Response.new([{ type: "text", text: text }])
    end

    def self.error_response(text)
      MCP::Tool::Response.new([{ type: "text", text: "❌ #{text}" }])
    end

    # --- Core API Request Logic ---
    
    # Main method for sending HTTP requests to Azure DevOps API
    def self.api_request(method, url, body = nil, content_type = "application/json")
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = case method
                when :get then Net::HTTP::Get.new(uri)
                when :post then Net::HTTP::Post.new(uri)
                when :patch then Net::HTTP::Patch.new(uri)
                when :delete then Net::HTTP::Delete.new(uri)
                else raise ArgumentError, "Unsupported HTTP method: #{method}"
                end

      credentials = Base64.strict_encode64(":#{pat}")
      request["Authorization"] = "Basic #{credentials}"
      request["Content-Type"] = content_type

      request.body = body.is_a?(String) ? body : body.to_json if body

      response = http.request(request)

      if response.code.to_i >= 200 && response.code.to_i < 300
        response.body.empty? ? {} : JSON.parse(response.body)
      else
        raise "API Error (#{response.code}): #{response.body[0..200]}"
      end
    end
  end
end