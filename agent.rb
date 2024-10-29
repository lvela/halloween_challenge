# frozen_string_literal: true

require './claude_client'
require './openai_client'
require './web_searcher'

class Agent
  SUMMARIZE_PROMPT = 'Please analyze and summarize the following content. ' \
    'Focus on key points and ensure information is accurate and well-organized.\n\n'

  CREATE_STORY_PROMPT = 'Please create a spooky Halloween story based on the following content. ' \
    'Keep it 3 paragraphs. Do not use more that 300 tokens.\n\n'

  def initialize(claude_key: nil, openai_key: nil)
    @claude_client = ClaudeClient.new(claude_key)
    @openai_client = OpenAIClient.new(openai_key)

    raise 'API key is required.' if @claude_client.nil? || @openai_client.nil?
  end

  def summarize(query, num_results: 3)
    content = WebSearcher.new.search(query, num_results:)

    summary_prompt = "#{SUMMARIZE_PROMPT}<content>#{content}</content>"

    # Generate summaries based on specified provider
    summaries = {}
    puts '-----------------'
    puts "Running claude prompt: #{summary_prompt[0..350]}..."
    summaries[:claude] = @claude_client.send(summary_prompt)

    puts '-----------------'
    puts "Running openai prompt: #{summary_prompt[0..350]}..."
    summaries[:openai] = @openai_client.send(summary_prompt)

    summaries
  end

  def create_stories(query, num_results: 3)
    content = WebSearcher.new.search(query, num_results:)

    create_story_prompt = "#{CREATE_STORY_PROMPT}<content>#{content}</content>"

    stories = {}
    puts '-----------------'
    puts "Running claude prompt: #{create_story_prompt[0..350]}..."
    stories[:claude] = @claude_client.send(create_story_prompt)

    puts '-----------------'
    puts "Running openai prompt: #{create_story_prompt[0..350]}..."
    stories[:openai] = @openai_client.send(create_story_prompt)

    stories
  end
end
