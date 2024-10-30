# frozen_string_literal: true

require 'dotenv'
require './agent'

def print_logo
  puts <<~'ASCII_ART'
     ________   ___  ________  ___  ___  _________  _____ ______   ________  ________  _______
    |\   ___  \|\  \|\   ____\|\  \|\  \|\___   ___\\   _ \  _   \|\   __  \|\   __  \|\  ___ \
    \ \  \\ \  \ \  \ \  \___|\ \  \\\  \|___ \  \_\ \  \\\__\ \  \ \  \|\  \ \  \|\  \ \   __/|
     \ \  \\ \  \ \  \ \  \  __\ \   __  \   \ \  \ \ \  \\|__| \  \ \   __  \ \   _  _\ \  \_|/__
      \ \  \\ \  \ \  \ \  \|\  \ \  \ \  \   \ \  \ \ \  \    \ \  \ \  \ \  \ \  \\  \\ \  \_|\ \
       \ \__\\ \__\ \__\ \_______\ \__\ \__\   \ \__\ \ \__\    \ \__\ \__\ \__\ \__\\ _\\ \_______\
        \|__| \|__|\|__|\|_______|\|__|\|__|    \|__|  \|__|     \|__|\|__|\|__|\|__|\|__|\|_______|



     ________   ________  ________  ________  ________  _________  ___  ___      ___ _______           ________  ___
    |\   ___  \|\   __  \|\   __  \|\   __  \|\   __  \|\___   ___\\  \|\  \    /  /|\  ___ \         |\   __  \|\  \
    \ \  \\ \  \ \  \|\  \ \  \|\  \ \  \|\  \ \  \|\  \|___ \  \_\ \  \ \  \  /  / | \   __/|        \ \  \|\  \ \  \
     \ \  \\ \  \ \   __  \ \   _  _\ \   _  _\ \   __  \   \ \  \ \ \  \ \  \/  / / \ \  \_|/__       \ \   __  \ \  \
      \ \  \\ \  \ \  \ \  \ \  \\  \\ \  \\  \\ \  \ \  \   \ \  \ \ \  \ \    / /   \ \  \_|\ \       \ \  \ \  \ \  \
       \ \__\\ \__\ \__\ \__\ \__\\ _\\ \__\\ _\\ \__\ \__\   \ \__\ \ \__\ \__/ /     \ \_______\       \ \__\ \__\ \__\
        \|__| \|__|\|__|\|__|\|__|\|__|\|__|\|__|\|__|\|__|    \|__|  \|__|\|__|/       \|_______|        \|__|\|__|\|__|
  ASCII_ART
  puts "\n"
end

if __FILE__ == $PROGRAM_NAME
  Dotenv.load

  puts ENV['OPENAI_API_KEY']

  if ENV['ANTHROPIC_API_KEY'].nil? || ENV['OPENAI_API_KEY'].nil?
    puts 'Please set ANTHROPIC_API_KEY and OPENAI_API_KEY in .env file.'
    return
  end

  agent = Agent.new(
    claude_key: ENV['ANTHROPIC_API_KEY'],
    openai_key: ENV['OPENAI_API_KEY']
  )

  begin
    print_logo

    summary_results = agent.summarize(
      ARGV[0] || 'worst disasters caused by software bugs',
      num_results: 3
    )

    puts "\n\nClaude's Summary:"
    puts '---------------------'
    puts summary_results[:claude]

    puts "\n\nOpenAI's Summary:"
    puts '---------------------'
    puts summary_results[:openai]

    story_results = agent.create_stories(
      ARGV[0] || 'worst disasters caused by software bugs',
      num_results: 3
    )

    puts "\n\nClaude's Story:"
    puts '---------------------'
    puts story_results[:claude]

    puts "\n\nOpenAI's Story:"
    puts '---------------------'
    puts story_results[:openai]
  end
end
