# frozen_string_literal: true

require 'openai'

class OpenAIClient
  def initialize(api_key)
    @client = ::OpenAI::Client.new(access_token: api_key)
  end

  def send(prompt)
    response = @client.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: [{ role: 'user', content: prompt }],
        max_tokens: 1000,
        temperature: 0.7
      }
    )

    response.dig('choices', 0, 'message', 'content')
  end
end
