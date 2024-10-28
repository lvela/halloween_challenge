# frozen_string_literal: true

require 'httparty'
require 'nokogiri'
require 'openai'
require 'dotenv'
require 'json'

class AIProvider
  class Claude
    BASE_URL = 'https://api.anthropic.com/v1/messages'

    def initialize(api_key)
      @api_key = api_key
    end

    def summarize(content)
      headers = {
        'x-api-key': @api_key,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json'
      }

      body = {
        model: 'claude-3-sonnet-20240229',
        max_tokens: 1000,
        temperature: 0.7,
        messages: [{
          role: 'user',
          content: "Please analyze and summarize the following content. Focus on key points and ensure information is accurate and well-organized:\n\n#{content}"
        }]
      }

      response = HTTParty.post(
        BASE_URL,
        headers:,
        body: body.to_json
      )

      if response.success?
        JSON.parse(response.body)['content'][0]['text']
      else
        raise "Claude API error: #{response.code} - #{response.body}"
      end
    end
  end

  class OpenAI
    def initialize(api_key)
      @client = ::OpenAI::Client.new(access_token: api_key)
    end

    def summarize(content)
      response = @client.chat(
        parameters: {
          model: 'gpt-3.5-turbo',
          messages: [{
            role: 'user',
            content: "Please analyze and summarize the following content. Focus on key points and ensure information is accurate and well-organized:\n\n#{content}"
          }],
          max_tokens: 1000,
          temperature: 0.7
        }
      )

      response.dig('choices', 0, 'message', 'content')
    end
  end
end

class WebSearchAgent
  def initialize(claude_key: nil, openai_key: nil)
    @claude = claude_key ? AIProvider::Claude.new(claude_key) : nil
    @openai = openai_key ? AIProvider::OpenAI.new(openai_key) : nil
    # @claude = nil
    # @openai = nil

    raise 'At least one AI provider API key is required' if @claude.nil? && @openai.nil?
  end

  def search_and_summarize(query, num_results: 3, provider: :both)
    # Fetch and process web content
    contents = search_and_extract(query, num_results)

    # Generate summaries based on specified provider
    case provider
    when :claude
      raise 'Claude API key not provided' if @claude.nil?

      { claude: @claude.summarize(contents) }
    when :openai
      raise 'OpenAI API key not provided' if @openai.nil?

      { openai: @openai.summarize(contents) }
    when :both
      summaries = {}
      summaries[:claude] = @claude.summarize(contents) if @claude
      summaries[:openai] = @openai.summarize(contents) if @openai
      summaries
    else
      raise 'Invalid provider specified. Use :claude, :openai, or :both'
    end
  end

  private

  def search_and_extract(query, num_results)
    # Search using DuckDuckGo
    urls = search_duckduckgo(query, num_results)

    # Extract and combine content from URLs
    contents = urls.map do |url|
      puts "Extracting content from: #{url}"
      extract_content(url)
    rescue StandardError => e
      puts "Error extracting content from #{url}: #{e.message}"
      nil
    end.compact

    contents.join("\n\n---\n\n")
  end

  def search_duckduckgo(query, num_results)
    encoded_query = URI.encode_www_form_component(query)
    url = "https://html.duckduckgo.com/html/?q=#{encoded_query}"

    response = HTTParty.get(url, headers: { 'User-Agent' => 'Mozilla/5.0' })
    doc = Nokogiri::HTML(response.body)

    doc.css('.result__url').map(&:text).first(num_results)
  end

  def extract_content(url)
    url = clean_content(url)
    response = HTTParty.get("https://#{url}", headers: { 'User-Agent' => 'Mozilla/5.0' })
    doc = Nokogiri::HTML(response.body)

    # Remove non-content elements
    doc.css('script, style, nav, header, footer, .ads').each(&:remove)

    # Extract main content
    main_content = doc.css('main, article, .content, .main-content').text
    puts "main_content: #{main_content}"
    main_content = doc.css('body').text if main_content.empty?

    clean_content(main_content)
  end

  def clean_content(text)
    # Remove excess whitespace and normalize text
    text.gsub(/\s+/, ' ')
        .gsub(/\n+/, "\n")
        .strip
  end
end

# Example usage:
if __FILE__ == $PROGRAM_NAME
  Dotenv.load

  # Initialize with both APIs
  agent = WebSearchAgent.new(
    claude_key: ENV['ANTHROPIC_API_KEY'],
    openai_key: ENV['OPENAI_API_KEY']
  )

  begin
    # Get summaries from both AIs
    results = agent.search_and_summarize(
      'worst disasters caused by software bugs',
      num_results: 3,
      provider: :both
    )

    puts "\nClaude's Summary:"
    puts '----------------'
    puts results[:claude]

    puts "\nOpenAI's Summary:"
    puts '----------------'
    puts results[:openai]
  rescue StandardError => e
    puts "Error: #{e.message}"
  end

  # Example with single provider
  begin
    claude_only = agent.search_and_summarize(
      'worst disasters caused by software bugs',
      provider: :claude
    )

    puts "\nClaude's Summary of Space Tourism:"
    puts '--------------------------------'
    puts claude_only[:claude]
  rescue StandardError => e
    puts "Error: #{e.message}"
  end
end
