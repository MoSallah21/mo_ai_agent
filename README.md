# mo_ai_agent

# AI Assistant

An AI-powered assistant built with Flutter that runs entirely on-device with no backend dependencies.

## Features

- Chat with an AI assistant powered by OpenAI's GPT models
- Store conversation history locally
- Light and dark mode support
- No server-side dependencies
- Clean architecture with BLoC/Cubit pattern

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- OpenAI API key

### Installation

1. Clone the repository
2. Create a `.env` file in the root directory with your OpenAI API key:
```
OPENAI_API_KEY=your_api_key_here
```
3. Run `flutter pub get` to install dependencies
4. Run the app with `flutter run`

Alternatively, you can input your API key directly in the app settings.

## Architecture

This app follows clean architecture principles with the following layers:

- **Presentation**: UI components, screens, and BLoC/Cubit state management
- **Domain**: Business logic, entities, and use cases
- **Data**: Repositories, data sources, and models

## Libraries Used

- flutter_bloc: State management
- sqflite: Local database storage
- http: API communication
- flutter_markdown: Markdown rendering
- flutter_dotenv: Environment variable management
- equatable: Value equality
- get_it: Dependency injection

## License