# frozen_string_literal: true

require 'openai'

class OpenAIClient
  SUMMARIZE_PROMPT = 'Please analyze and summarize the following content. ' \
    'Focus on key points and ensure information is accurate and well-organized:\n\n'

  def initialize(api_key)
    @client = ::OpenAI::Client.new(access_token: api_key)
  end

  def send(content)
    response = @client.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: [{ role: 'user', content: "#{SUMMARIZE_PROMPT}<content>#{content}</content>" }],
        max_tokens: 1000,
        temperature: 0.7
      }
    )

    response.dig('choices', 0, 'message', 'content')
  end
end
