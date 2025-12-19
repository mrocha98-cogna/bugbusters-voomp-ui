class ApiEndpoints {
  // API 1: Exemplo - Validação de email
  static const String apiVoompBaseUrl =
      'http://54.205.228.168';
      // 'https://unshieldable-condescendingly-mathilda.ngrok-free.dev';
      // 'http://ec2-44-220-147-143.compute-1.amazonaws.com';
  static const String getWhatsappLink = '/api/v1/whatsapp/start-url';
  static const String whatsappUserStatus = '/api/v1/users/whatsapp-alerts/status';
  static const String userPendingSteps = '/api/v1/users/pending-steps';
  static const String patchUserIdentityValidation = '/api/v1/users/identity-validation';
  static const String postUserBusinessData = '/api/v1/users/business-data';
  static const String validationEmailToken = '/api/v1/email/send';
  static const String login = '/api/v1/auth/login';
  static const String signUp = '/api/v1/auth/sign-up';
  static const String generationCode = '/api/v1/generation-code';
  static const String generationCodeUse = '/api/v1/generation-code/use';
  static const String productsList = '/api/v1/products';
  static const String productDetail = '/api/v1/products';
  static const String createProduct = '/api/v1/products';
  static const String updateProduct = '/api/v1/products';
  static const String deleteProduct = '/api/v1/products';
  static const String iaOptimizeTitle = '/api/v1/ia/optimize-title';
  static const String iaOptimizeDescription = '/api/v1/ia/optimize-descriptor';

  static const String salesTotal = '/api/v1/sales/total';
  static const String salesStatistics = '/api/v1/sales/statistics';
  static const String salesRevenue = '/api/v1/sales/revenue';
}
