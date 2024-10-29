# frozen_string_literal: true

require 'openai'

class OpenAIClient
  def initialize(api_key)
    @client = ::OpenAI::Client.new(access_token: api_key)
  end

  def send(prompt)
    response = @client.chat(
      parameters: {
        model: 'gpt-4o',
        messages: [{ role: 'user', content: prompt }],
        max_tokens: 800,
        temperature: 1.0
      }
    )

    response.dig('choices', 0, 'message', 'content')
  end
end
