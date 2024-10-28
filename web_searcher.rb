# frozen_string_literal: true

require 'httparty'
require 'nokogiri'

class WebSearcher
  def initialize; end

  def search(query, num_results: 3)
    # Fetch and process web content
    search_and_extract(query, num_results)
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
    url = remove_whitespace(url)
    response = HTTParty.get("https://#{url}", headers: { 'User-Agent' => 'Mozilla/5.0' })
    doc = Nokogiri::HTML(response.body)
    puts "doc length: #{doc.text.length}"

    # Remove non-content elements
    # doc.css('script, style, nav, header, footer, .ads').each(&:remove)
    doc.css('script, style').each(&:remove)
    # puts "content after remove: #{doc.text.length}"

    # Extract main content
    # main_content = doc.css('main, article, .content, .main-content').text
    # puts "content length before : #{main_content.length}"
    main_content = doc.css('body').text # if main_content.empty?
    puts "content length: #{main_content.length}"

    "Content from: #{url}\n\n#{remove_whitespace(main_content)}"
  end

  def remove_whitespace(text)
    # Remove excess whitespace and normalize text
    text.gsub(/\s+/, ' ')
        .gsub(/\n+/, "\n")
        .strip
  end
end
