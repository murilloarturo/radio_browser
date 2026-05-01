class OpenAiConfig {
  const OpenAiConfig({
    required this.apiKey,
    required this.model,
    required this.transcriptionModel,
    this.baseUrl = 'https://api.openai.com/v1',
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 30),
  });

  static const production = OpenAiConfig(
    apiKey: String.fromEnvironment('OPENAI_API_KEY'),
    model: String.fromEnvironment('OPENAI_MODEL', defaultValue: 'gpt-5-mini'),
    transcriptionModel: String.fromEnvironment(
      'OPENAI_TRANSCRIPTION_MODEL',
      defaultValue: 'gpt-4o-mini-transcribe',
    ),
  );

  final String apiKey;
  final String model;
  final String transcriptionModel;
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  bool get isEnabled => apiKey.trim().isNotEmpty;
}
