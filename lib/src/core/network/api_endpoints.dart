class ApiEndpoints {
  // API 1: Exemplo - Validação de email
  static const String apiVoompBaseUrl = 'https://unshieldable-condescendingly-mathilda.ngrok-free.dev';
  static const String validationEmailToken = '/api/v1/email/send';
  static const String login = '/api/v1/auth/login';
  static const String signUp = '/api/v1/auth/sign-up';
  static const String generationCode = '/api/v1/generation-code';
  static const String generationCodeUse = '/api/v1/generation-code/use';

  // API 2: Exemplo - API whatsapp
  static const String apiWhatsappBaseUrl = 'https://whatsapp.com';
  static const String logs = '/api/v1/whatsapp/start-url';
}