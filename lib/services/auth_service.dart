import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  String? _token;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null && _token != null;

  final ApiService _apiService = ApiService();

  // USUÁRIOS DE TESTE - CORRIGIDO PARA USAR TIPOS CORRETOS
  final Map<String, Map<String, dynamic>> _testUsers = {
    'admin@test.com': {
      'password': '123456',
      'userData': {
        'id': 1, // int em vez de String
        'name': 'Administrador',
        'email': 'admin@test.com',
        'userType': Constants.adminType,
        'phone': '(11) 99999-9999',
        'location': 'São Paulo, SP',
        'securityQuestion': 'Qual o nome do seu primeiro animal de estimação?',
        'securityAnswer': 'Rex',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      }
    },
    'tutor@test.com': {
      'password': '123456',
      'userData': {
        'id': 2,
        'name': 'João Silva',
        'email': 'tutor@test.com',
        'userType': Constants.tutorType,
        'phone': '(11) 88888-8888',
        'location': 'Rio de Janeiro, RJ',
        'securityQuestion': 'Qual o nome da sua mãe?',
        'securityAnswer': 'Maria',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      }
    },
    'lojista@test.com': {
      'password': '123456',
      'userData': {
        'id': 3,
        'name': 'Pet Shop Central',
        'email': 'lojista@test.com',
        'userType': Constants.lojistaType,
        'phone': '(11) 77777-7777',
        'location': 'Belo Horizonte, MG',
        'cnpj': '12.345.678/0001-90',
        'responsibleName': 'Carlos Silva',
        'storeType': Constants.physicalStore,
        'operatingHours': '08:00 às 18:00',
        'securityQuestion': 'Qual o nome da cidade onde você nasceu?',
        'securityAnswer': 'Belo Horizonte',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      }
    },
    'vet@test.com': {
      'password': '123456',
      'userData': {
        'id': 4,
        'name': 'Dr. Maria Santos',
        'email': 'vet@test.com',
        'userType': Constants.veterinarioType,
        'phone': '(11) 66666-6666',
        'location': 'Salvador, BA',
        'crmv': 'BA 1234',
        'securityQuestion': 'Qual o nome da sua escola primária?',
        'securityAnswer': 'Escola Municipal',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      }
    },
  };

  AuthService() {
    _loadUserFromStorage();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(Constants.tokenKey);
      final userJson = prefs.getString(Constants.userKey);

      if (token != null && userJson != null) {
        _token = token;
        _currentUser = User.fromJson(jsonDecode(userJson));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados do usuário: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);

      // VERIFICAR USUÁRIOS DE TESTE PRIMEIRO
      final testUser = _testUsers[email.toLowerCase()];
      if (testUser != null && testUser['password'] == password) {
        // Login com usuário de teste
        _token = 'test_token_${DateTime.now().millisecondsSinceEpoch}';
        
        try {
          _currentUser = User.fromJson(testUser['userData'] as Map<String, dynamic>);
          await _saveUserToStorage();
          notifyListeners();
          return true;
        } catch (e) {
          debugPrint('Erro ao criar usuário a partir dos dados de teste: $e');
          debugPrint('Dados: ${testUser['userData']}');
          return false;
        }
      }

      // SE NÃO FOR USUÁRIO DE TESTE, TENTAR API (quando tiver backend)
      try {
        final response = await _apiService.post(
          Constants.loginEndpoint,
          {
            'email': email,
            'password': password,
          },
        );

        if (response['success'] == true) {
          _token = response['data']['token'];
          _currentUser = User.fromJson(response['data']['user']);

          await _saveUserToStorage();
          notifyListeners();
          return true;
        }
      } catch (e) {
        // Se a API falhar (não tem backend ainda), retorna false
        debugPrint('API não disponível, usando apenas usuários de teste');
      }

      return false;
    } catch (e) {
      debugPrint('Erro no login: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    try {
      _setLoading(true);

      // PARA TESTE: aceitar qualquer registro
      if (userData['email'] != null && userData['password'] != null) {
        // Gerar ID único
        final newId = _testUsers.length + 10;
        
        // Adicionar aos usuários de teste temporariamente
        final email = userData['email'].toLowerCase();
        _testUsers[email] = {
          'password': userData['password'],
          'userData': {
            'id': newId,
            'name': userData['name'] ?? 'Usuário',
            'email': userData['email'],
            'userType': userData['userType'] ?? Constants.tutorType,
            'phone': userData['phone'] ?? '',
            'location': userData['location'] ?? '',
            'cnpj': userData['cnpj'] ?? '',
            'crmv': userData['crmv'] ?? '',
            'responsibleName': userData['responsibleName'] ?? '',
            'storeType': userData['storeType'] ?? Constants.physicalStore,
            'operatingHours': userData['operatingHours'] ?? '',
            'securityQuestion': userData['securityQuestion'] ?? 'Qual o nome do seu primeiro animal de estimação?',
            'securityAnswer': userData['securityAnswer'] ?? '',
            'isActive': true,
            'createdAt': DateTime.now().toIso8601String(),
          }
        };
        return true;
      }

      // Tentar API se disponível
      try {
        final response = await _apiService.post(
          Constants.registerEndpoint,
          userData,
        );

        if (response['success'] == true) {
          return true;
        }
      } catch (e) {
        debugPrint('API não disponível para registro');
      }

      return false;
    } catch (e) {
      debugPrint('Erro no registro: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> forgotPassword(String email, String question, String answer) async {
    try {
      _setLoading(true);

      // Verificar usuários de teste
      final testUser = _testUsers[email.toLowerCase()];
      if (testUser != null) {
        final userData = testUser['userData'] as Map<String, dynamic>;
        if (userData['securityQuestion'] == question && 
            userData['securityAnswer']?.toLowerCase() == answer.toLowerCase()) {
          return true;
        }
        return false;
      }

      // Tentar API
      final response = await _apiService.post(
        Constants.forgotPasswordEndpoint,
        {
          'email': email,
          'securityQuestion': question,
          'securityAnswer': answer,
        },
      );

      return response['success'] == true;
    } catch (e) {
      debugPrint('Erro na recuperação de senha: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email, String newPassword, String token) async {
    try {
      _setLoading(true);

      // Para usuários de teste, apenas atualizar a senha
      final testUser = _testUsers[email.toLowerCase()];
      if (testUser != null) {
        testUser['password'] = newPassword;
        return true;
      }

      final response = await _apiService.post(
        Constants.resetPasswordEndpoint,
        {
          'email': email,
          'newPassword': newPassword,
          'resetToken': token,
        },
      );

      return response['success'] == true;
    } catch (e) {
      debugPrint('Erro na redefinição de senha: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      _setLoading(true);

      // Limpar dados locais
      _currentUser = null;
      _token = null;

      // Limpar storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(Constants.tokenKey);
      await prefs.remove(Constants.userKey);
      await prefs.remove(Constants.userTypeKey);

      notifyListeners();
    } catch (e) {
      debugPrint('Erro no logout: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _saveUserToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_token != null) {
        await prefs.setString(Constants.tokenKey, _token!);
      }
      
      if (_currentUser != null) {
        await prefs.setString(Constants.userKey, jsonEncode(_currentUser!.toJson()));
        await prefs.setString(Constants.userTypeKey, _currentUser!.userType);
      }
    } catch (e) {
      debugPrint('Erro ao salvar dados do usuário: $e');
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    try {
      _setLoading(true);

      final response = await _apiService.put(
        '${Constants.usersEndpoint}/${_currentUser?.id}',
        userData,
        token: _token,
      );

      if (response['success'] == true) {
        _currentUser = User.fromJson(response['data']);
        await _saveUserToStorage();
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Erro ao atualizar perfil: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> getSecurityQuestion(String email) async {
    try {
      // Verificar usuários de teste
      final testUser = _testUsers[email.toLowerCase()];
      if (testUser != null) {
        final userData = testUser['userData'] as Map<String, dynamic>;
        return userData['securityQuestion'];
      }

      final response = await _apiService.get(
        '${Constants.forgotPasswordEndpoint}/question?email=$email',
      );

      if (response['success'] == true) {
        return response['data']['question'];
      }

      return null;
    } catch (e) {
      debugPrint('Erro ao buscar pergunta de segurança: $e');
      return null;
    }
  }

  String getHomepageRoute() {
    if (_currentUser == null) return '/login';

    switch (_currentUser!.userType) {
      case Constants.adminType:
        return '/admin';
      case Constants.lojistaType:
        return '/lojista';
      case Constants.tutorType:
        return '/tutor';
      case Constants.veterinarioType:
        return '/veterinario';
      default:
        return '/login';
    }
  }

  bool canAccessRoute(String route) {
    if (_currentUser == null) return false;

    switch (route) {
      case '/admin':
        return _currentUser!.userType == Constants.adminType;
      case '/lojista':
        return _currentUser!.userType == Constants.lojistaType;
      case '/tutor':
        return _currentUser!.userType == Constants.tutorType;
      case '/veterinario':
        return _currentUser!.userType == Constants.veterinarioType;
      default:
        return true;
    }
  }

  // MÉTODO PARA VER USUÁRIOS DE TESTE
  String getTestUsersInfo() {
    return '''
USUÁRIOS DE TESTE:

ADMINISTRADOR:
Email: admin@test.com
Senha: 123456

TUTOR:
Email: tutor@test.com  
Senha: 123456

LOJISTA:
Email: lojista@test.com
Senha: 123456

VETERINÁRIO:
Email: vet@test.com
Senha: 123456
    ''';
  }
}