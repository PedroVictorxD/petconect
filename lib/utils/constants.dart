class Constants {
  // API Base URL - ajuste conforme seu backend Spring Boot
  static const String baseUrl = 'http://127.0.0.1:8080/api';
  
  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String resetPasswordEndpoint = '/auth/reset-password';
  static const String productsEndpoint = '/products';
  static const String servicesEndpoint = '/services';
  static const String usersEndpoint = '/users';
  static const String petsEndpoint = '/pets';
  
  // User Types
  static const String adminType = 'ADMINISTRADOR';
  static const String lojistaType = 'LOJISTA';
  static const String tutorType = 'TUTOR';
  static const String veterinarioType = 'VETERINARIO';
  
  // Store Types
  static const String virtualStore = 'VIRTUAL';
  static const String physicalStore = 'FISICA';
  
  // Activity Levels
  static const List<String> activityLevels = [
    'BAIXA',
    'MODERADA',
    'ALTA',
    'MUITO_ALTA'
  ];
  
  // Pet Types
  static const List<String> petTypes = [
    'CACHORRO',
    'GATO',
    'PASSARO',
    'PEIXE',
    'OUTRO'
  ];
  
  // Measurement Units
  static const List<String> measurementUnits = [
    'KG',
    'G',
    'L',
    'ML',
    'UNIDADE',
    'PACOTE'
  ];
  
  // Security Questions
  static const List<String> securityQuestions = [
    'Qual o nome do seu primeiro animal de estimação?',
    'Qual o nome da sua mãe?',
    'Qual o nome da cidade onde você nasceu?',
    'Qual o nome da sua escola primária?',
    'Qual sua comida favorita?',
    'Qual o nome do seu melhor amigo de infância?',
  ];
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 500;
  
  // Messages
  static const String loginSuccessMessage = 'Login realizado com sucesso!';
  static const String loginErrorMessage = 'Email ou senha incorretos.';
  static const String registerSuccessMessage = 'Cadastro realizado com sucesso!';
  static const String registerErrorMessage = 'Erro ao realizar cadastro.';
  static const String passwordResetSuccessMessage = 'Senha redefinida com sucesso!';
  static const String passwordResetErrorMessage = 'Erro ao redefinir senha.';
  static const String genericErrorMessage = 'Ocorreu um erro. Tente novamente.';
  static const String networkErrorMessage = 'Erro de conexão. Verifique sua internet.';
  static const String sessionExpiredMessage = 'Sessão expirada. Faça login novamente.';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String userTypeKey = 'user_type';
}