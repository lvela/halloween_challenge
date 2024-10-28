# frozen_string_literal: true

require 'httparty'
require 'nokogiri'
require 'dotenv'
require 'json'

require './claude_client'
require './openai_client'
require './web_searcher'

class SearchAgent
  SUMMARIZE_PROMPT = 'Please analyze and summarize the following content. ' \
    'Focus on key points and ensure information is accurate and well-organized:\n\n'

  def initialize(claude_key: nil, openai_key: nil)
    @claude_client = ClaudeClient.new(claude_key)
    @openai_client = OpenAIClient.new(openai_key)

    raise 'API key is required.' if @claude_client.nil? || @openai_client.nil?
  end

  def summarize(query, num_results: 3)
    content = WebSearcher.new.search(query, num_results:)

    prompt = "#{SUMMARIZE_PROMPT}<content>#{content}</content>"

    # Generate summaries based on specified provider
    summaries = {}
    summaries[:claude] = @claude_client.send(prompt)
    summaries[:openai] = @openai_client.send(prompt)
    summaries
  end
end

# Example usage:
if __FILE__ == $PROGRAM_NAME
  Dotenv.load

  # Initialize with both APIs
  agent = SearchAgent.new(
    claude_key: ENV['ANTHROPIC_API_KEY'],
    openai_key: ENV['OPENAI_API_KEY']
  )

  begin
    # Get summaries from both AIs
    results = agent.summarize(
      'worst disasters caused by software bugs',
      num_results: 3
    )

    puts "\nClaude's Summary:"
    puts '----------------'
    puts results[:claude]

    puts "\nOpenAI's Summary:"
    puts '----------------'
    puts results[:openai]
  end
end
