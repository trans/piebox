require "http/client"
require "json"

module Piebox
  module AI
    class AnthropicClient < Client
      API_URL = "https://api.anthropic.com/v1/messages"

      def initialize(@api_key : String, @model : String = "claude-haiku-4-5-20251001")
      end

      def generate(prompt : String) : String
        body = {
          model:      @model,
          max_tokens: 256,
          messages:   [{role: "user", content: prompt}],
        }.to_json

        headers = HTTP::Headers{
          "Content-Type"      => "application/json",
          "x-api-key"         => @api_key,
          "anthropic-version" => "2023-06-01",
        }

        uri = URI.parse(API_URL)
        client = HTTP::Client.new(uri)
        client.read_timeout = 30.seconds
        response = client.post(uri.path.not_nil!, headers: headers, body: body)

        if response.status_code == 200
          result = JSON.parse(response.body)
          content = result["content"].as_a
          if first = content.first?
            first["text"].as_s
          else
            ""
          end
        else
          raise "Anthropic API error (#{response.status_code}): #{response.body}"
        end
      end
    end
  end
end
