# frozen_string_literal: true

require 'httparty'
require 'nokogiri'

class WebSearcher
  def initialize; end

  def search(query, num_results: 3)
    search_and_extract(query, num_results)
  end

  private

  def search_and_extract(query, num_results)
    puts "Searching for: \"#{query}\""
    urls = search_duckduckgo(query, num_results)

    contents = urls.map do |url|
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

    puts "Extracting content from: #{url}"

    response = HTTParty.get("https://#{url}", headers: { 'User-Agent' => 'Mozilla/5.0' })
    doc = Nokogiri::HTML(response.body)
    puts "length: #{doc.text.length}"

    doc.css('script, style').each(&:remove)

    main_content = doc.css('body').text
    puts "main content length: #{main_content.length}"

    "Content from: #{url}\n\n<content>#{remove_whitespace(main_content)}</content>"
  end

  def remove_whitespace(text)
    text.gsub(/\s+/, ' ')
        .gsub(/\n+/, "\n")
        .strip
  end
end
