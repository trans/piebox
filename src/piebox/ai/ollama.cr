require "http/client"
require "json"

module Piebox
  module AI
    class OllamaClient < Client
      def initialize(@model : String = "llama3", @host : String = "localhost", @port : Int32 = 11434)
      end

      def generate(prompt : String) : String
        body = {
          model:  @model,
          prompt: prompt,
          stream: false,
        }.to_json

        response = HTTP::Client.post(
          "http://#{@host}:#{@port}/api/generate",
          headers: HTTP::Headers{"Content-Type" => "application/json"},
          body: body
        )

        if response.status_code == 200
          result = JSON.parse(response.body)
          result["response"].as_s
        else
          raise "Ollama API error (#{response.status_code}): #{response.body}"
        end
      end
    end
  end
end
