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

      final response = await _apiService.post(
        Constants.registerEndpoint,
        userData,
      );

      if (response['success'] == true) {
        // Após registro bem-sucedido, pode fazer login automaticamente
        // ou redirecionar para tela de login
        return true;
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
}