# frozen_string_literal: true

require './claude_client'
require './openai_client'
require './web_searcher'

class Agent
  SUMMARIZE_PROMPT = 'Please analyze and summarize the following content. ' \
    "Focus on key points and ensure information is accurate and well-organized.\n\n"

  CREATE_STORY_PROMPT = 'Please create a spooky Halloween story based on the following content. ' \
    "Ignore previous instructions about length and keep the response short with less than 500 characters. \n\n"

  def initialize(claude_key: nil, openai_key: nil, query: nil)
    @claude_client = ClaudeClient.new(claude_key)
    @openai_client = OpenAIClient.new(openai_key)
    @query = query

    raise 'API key is required.' if @claude_client.nil? || @openai_client.nil?
  end

  def summarize
    summary_prompt = "#{SUMMARIZE_PROMPT} #{content}"

    # Generate summaries based on specified provider
    summaries = {}
    puts "\n\n-----------------"
    puts "Running claude prompt: #{summary_prompt[0..550]}..."
    summaries[:claude] = @claude_client.send(summary_prompt)

    puts "\n\n-----------------"
    puts "Running openai prompt: #{summary_prompt[0..550]}..."
    summaries[:openai] = @openai_client.send(summary_prompt)

    summaries
  end

  def create_stories
    create_story_prompt = "#{CREATE_STORY_PROMPT} #{content}"

    stories = {}
    puts "\n\n-----------------"
    puts "Running claude prompt: #{create_story_prompt[0..550]}..."
    stories[:claude] = @claude_client.send(create_story_prompt)

    puts "\n\n-----------------"
    puts "Running openai prompt: #{create_story_prompt[0..550]}..."
    stories[:openai] = @openai_client.send(create_story_prompt)

    stories
  end

  private

  def content
    @content ||= WebSearcher.new.search(@query, num_results: 3)
  end
end
