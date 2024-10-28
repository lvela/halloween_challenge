# frozen_string_literal: true

require 'httparty'
require 'nokogiri'
require 'dotenv'
require 'json'

require './claude_client'
require './openai_client'
require './web_searcher'

class SearchAgent
  def initialize(claude_key: nil, openai_key: nil)
    @claude = ClaudeClient.new(claude_key)
    @openai = OpenAIClient.new(openai_key)

    raise 'API key is required.' if @claude.nil? || @openai.nil?
  end

  def summarize(query, num_results: 3, provider: :both)
    contents = WebSearcher.new.search(query)

    # Generate summaries based on specified provider
    summaries = {}
    summaries[:claude] = @claude.send(contents)
    summaries[:openai] = @openai.send(contents)
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
    # rescue StandardError => e
    #   puts "Error: #{e.message}"
  end
end
