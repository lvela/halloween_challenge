# Project Setup and Installation

This guide will help you get started with running this Ruby project on your local machine.

## Prerequisites

Before you begin, ensure you have the following installed:
- Ruby (recommended version: 2.7 or higher)
- Bundler gem

## Installation

1. Clone this repository:
```bash
git clone <repository-url>
cd <project-directory>
```

2. Install dependencies using Bundler:
```bash
bundle install
```

This will install all the required gems specified in the `Gemfile`.

## Set environment variables
Create a .env file in the `src` directory and add the variables

```
OPENAI_API_KEY=<openai api key>
ANTHROPIC_API_KEY=<anthropic api key>
```

## Running the Application

To run the main application, use:
```bash
cd src
bundle exec ruby main.rb
```

This ensures the application runs with the correct gem versions installed by Bundler.

## Troubleshooting

If you encounter any issues:

### Bundle Install Errors
- Make sure you have Bundler installed:
```bash
gem install bundler
```
- Try clearing your Bundler cache:
```bash
bundle clean --force
```
- Update Bundler to the latest version:
```bash
gem update bundler
```

## Support

If you encounter any issues, please open an issue in the GitHub repository.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
