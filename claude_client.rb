# frozen_string_literal: true

require 'httparty'
require 'json'

class ClaudeClient
  SUMMARIZE_PROMPT = 'Please analyze and summarize the following content. ' \
    'Focus on key points and ensure information is accurate and well-organized:\n\n'

  def initialize(api_key)
    @api_key = api_key
  end

  def send(content)
    body = {
      model: 'claude-3-sonnet-20240229',
      max_tokens: 1000,
      temperature: 0.7,
      messages: [{ role: 'user', content: "#{SUMMARIZE_PROMPT}<content>#{content}</content>" }]
    }

    response = HTTParty.post(
      'https://api.anthropic.com/v1/messages',
      headers:,
      body: body.to_json
    )

    raise "Claude API error: #{response.code} - #{response.body}" unless response.success?

    JSON.parse(response.body)['content'][0]['text']
  end

  private

  def headers
    {
      'x-api-key': @api_key,
      'anthropic-version': '2023-06-01',
      'content-type': 'application/json'
    }
  end
end
