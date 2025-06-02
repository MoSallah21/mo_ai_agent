class AppConstants {
  static const String appName = 'Mo Ai Assistant';
  static const String placeholderText = 'Type your message...';
  static const String sendButtonText = 'Send';
  static const String settingsTitle = 'Settings';
  static const int messageMaxLines = 12;
  static const String modelInfo = 'Powered by MoSallah';

  // URLs
  static const String privacyPolicyUrl = 'https://example.com/privacy';
  static const String termsOfServiceUrl = 'https://example.com/terms';
  static const String supportUrl = 'https://example.com/support';
  static const String feedbackUrl = 'https://example.com/feedback';

  // Messages
  static const String welcomeMessage =
      'I\'m Mo Ai your assistant, ready to help answer questions, brainstorm ideas, '
      'write content, solve problems, and more. What can I help you with today?';

  // API Configuration
  static const String apiEndpoint = 'https://api.example.com/v1';
  static const int apiTimeoutSeconds = 60;
  static const int maxRetries = 3;

  // Local Storage Keys
  static const String conversationsKey = 'conversations';
  static const String messagesKey = 'messages';
  static const String apiKeyStorageKey = 'api_key';

  // UI Constants
  static const double maxMessageWidth = 0.8; // Percentage of screen width
  static const Duration typingAnimationDuration = Duration(milliseconds: 300);

  // Limits
  static const int maxMessageLength = 4000;
  static const int maxConversationTitleLength = 100;
  static const int maxConversationsToShow = 50;
}
