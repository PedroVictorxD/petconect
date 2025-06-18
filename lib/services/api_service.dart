import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 30);

  Map<String, String> _getHeaders({String? token, bool isMultipart = false}) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<Map<String, dynamic>> get(String endpoint, {String? token}) async {
    try {
      final url = Uri.parse('${Constants.baseUrl}$endpoint');
      
      final response = await http.get(
        url,
        headers: _getHeaders(token: token),
      ).timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    try {
      final url = Uri.parse('${Constants.baseUrl}$endpoint');
      
      final response = await http.post(
        url,
        headers: _getHeaders(token: token),
        body: jsonEncode(data),
      ).timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    try {
      final url = Uri.parse('${Constants.baseUrl}$endpoint');
      
      final response = await http.put(
        url,
        headers: _getHeaders(token: token),
        body: jsonEncode(data),
      ).timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    String? token,
  }) async {
    try {
      final url = Uri.parse('${Constants.baseUrl}$endpoint');
      
      final response = await http.delete(
        url,
        headers: _getHeaders(token: token),
      ).timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    String fieldName,
    String filePath, {
    String? token,
    Map<String, String>? additionalFields,
  }) async {
    try {
      final url = Uri.parse('${Constants.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', url);

      // Adicionar headers
      request.headers.addAll(_getHeaders(token: token, isMultipart: true));

      // Adicionar arquivo
      if (kIsWeb) {
        // Para Flutter Web, seria necessário implementar upload diferente
        // Por enquanto, retornamos erro
        throw UnsupportedError('Upload de arquivo não suportado na web');
      } else {
        request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
      }

      // Adicionar campos adicionais
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': data,
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Erro desconhecido',
          'statusCode': response.statusCode,
          'data': data,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro ao processar resposta do servidor',
        'statusCode': response.statusCode,
      };
    }
  }

  Map<String, dynamic> _handleError(dynamic error) {
    debugPrint('Erro na requisição: $error');

    if (error is SocketException) {
      return {
        'success': false,
        'error': 'Servidor não disponível. Usando dados de demonstração.',
        'data': _getDemoData(),
      };
    } else if (error is http.ClientException) {
      return {
        'success': false,
        'error': 'Servidor não disponível. Usando dados de demonstração.',
        'data': _getDemoData(),
      };
    } else {
      return {
        'success': false,
        'error': 'Erro desconhecido. Usando dados de demonstração.',
        'data': _getDemoData(),
      };
    }
  }

  Map<String, dynamic> _getDemoData() {
    // Retorna dados de demonstração quando o servidor não está disponível
    return {
      'users': [
        {
          'id': 1,
          'name': 'João Silva',
          'email': 'joao@example.com',
          'userType': 'ADMINISTRADOR',
          'cpf': '123.456.789-00',
          'phone': '(11) 99999-9999',
          'isActive': true,
          'createdAt': '2024-01-01T00:00:00Z',
        },
        {
          'id': 2,
          'name': 'Maria Santos',
          'email': 'maria@example.com',
          'userType': 'TUTOR',
          'cpf': '987.654.321-00',
          'phone': '(11) 88888-8888',
          'isActive': true,
          'createdAt': '2024-01-02T00:00:00Z',
        },
        {
          'id': 3,
          'name': 'Pedro Costa',
          'email': 'pedro@example.com',
          'userType': 'VETERINARIO',
          'cpf': '456.789.123-00',
          'phone': '(11) 77777-7777',
          'isActive': true,
          'createdAt': '2024-01-03T00:00:00Z',
        },
        {
          'id': 4,
          'name': 'Ana Oliveira',
          'email': 'ana@example.com',
          'userType': 'LOJISTA',
          'cpf': '789.123.456-00',
          'phone': '(11) 66666-6666',
          'isActive': true,
          'createdAt': '2024-01-04T00:00:00Z',
        },
      ],
      'products': [
        {
          'id': 1,
          'name': 'Ração Premium para Cães',
          'description': 'Ração de alta qualidade para cães adultos',
          'price': 89.90,
          'stock': 50,
          'ownerId': 4,
          'ownerName': 'Ana Oliveira',
          'imageUrl': 'https://images.unsplash.com/photo-1601758228041-3caa5d9c6c5f?w=400&h=300&fit=crop',
          'category': 'Alimentação',
          'isActive': true,
        },
        {
          'id': 2,
          'name': 'Brinquedo Interativo',
          'description': 'Brinquedo para estimular a mente do pet',
          'price': 45.00,
          'stock': 30,
          'ownerId': 4,
          'ownerName': 'Ana Oliveira',
          'imageUrl': 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=400&h=300&fit=crop',
          'category': 'Brinquedos',
          'isActive': true,
        },
      ],
      'services': [
        {
          'id': 1,
          'name': 'Consulta Veterinária',
          'description': 'Consulta geral para pets',
          'price': 120.00,
          'ownerId': 3,
          'ownerName': 'Pedro Costa',
          'imageUrl': 'https://images.unsplash.com/photo-1576201836106-db1758fd1c97?w=400&h=300&fit=crop',
          'category': 'Saúde',
          'isActive': true,
        },
        {
          'id': 2,
          'name': 'Vacinação',
          'description': 'Aplicação de vacinas essenciais',
          'price': 80.00,
          'ownerId': 3,
          'ownerName': 'Pedro Costa',
          'imageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=300&fit=crop',
          'category': 'Saúde',
          'isActive': true,
        },
      ],
      'pets': [
        {
          'id': 1,
          'name': 'Rex',
          'type': 'CACHORRO',
          'breed': 'Golden Retriever',
          'age': 3,
          'weight': 25.5,
          'ownerId': 2,
          'ownerName': 'Maria Santos',
          'imageUrl': 'https://images.unsplash.com/photo-1552053831-71594a27632d?w=400&h=300&fit=crop',
          'isActive': true,
        },
        {
          'id': 2,
          'name': 'Mia',
          'type': 'GATO',
          'breed': 'Persa',
          'age': 2,
          'weight': 4.2,
          'ownerId': 2,
          'ownerName': 'Maria Santos',
          'imageUrl': 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=300&fit=crop',
          'isActive': true,
        },
      ],
    };
  }

  // Métodos específicos para diferentes recursos
  Future<Map<String, dynamic>> getProducts({String? token, int? ownerId}) async {
    String endpoint = Constants.productsEndpoint;
    if (ownerId != null) {
      endpoint += '?ownerId=$ownerId';
    }
    return get(endpoint, token: token);
  }

  Future<Map<String, dynamic>> getServices({String? token, int? ownerId}) async {
    String endpoint = Constants.servicesEndpoint;
    if (ownerId != null) {
      endpoint += '?ownerId=$ownerId';
    }
    return get(endpoint, token: token);
  }

  Future<Map<String, dynamic>> getPets({String? token, int? ownerId}) async {
    String endpoint = Constants.petsEndpoint;
    if (ownerId != null) {
      endpoint += '?ownerId=$ownerId';
    }
    return get(endpoint, token: token);
  }

  Future<Map<String, dynamic>> getUsers({String? token, String? userType}) async {
    String endpoint = Constants.usersEndpoint;
    if (userType != null) {
      endpoint += '?userType=$userType';
    }
    return get(endpoint, token: token);
  }

  Future<Map<String, dynamic>> createProduct(
    Map<String, dynamic> productData, {
    String? token,
  }) async {
    return post(Constants.productsEndpoint, productData, token: token);
  }

  Future<Map<String, dynamic>> updateProduct(
    int productId,
    Map<String, dynamic> productData, {
    String? token,
  }) async {
    return put('${Constants.productsEndpoint}/$productId', productData, token: token);
  }

  Future<Map<String, dynamic>> deleteProduct(int productId, {String? token}) async {
    return delete('${Constants.productsEndpoint}/$productId', token: token);
  }

  Future<Map<String, dynamic>> createService(
    Map<String, dynamic> serviceData, {
    String? token,
  }) async {
    return post(Constants.servicesEndpoint, serviceData, token: token);
  }

  Future<Map<String, dynamic>> updateService(
    int serviceId,
    Map<String, dynamic> serviceData, {
    String? token,
  }) async {
    return put('${Constants.servicesEndpoint}/$serviceId', serviceData, token: token);
  }

  Future<Map<String, dynamic>> deleteService(int serviceId, {String? token}) async {
    return delete('${Constants.servicesEndpoint}/$serviceId', token: token);
  }

  Future<Map<String, dynamic>> createPet(
    Map<String, dynamic> petData, {
    String? token,
  }) async {
    return post(Constants.petsEndpoint, petData, token: token);
  }

  Future<Map<String, dynamic>> updatePet(
    int petId,
    Map<String, dynamic> petData, {
    String? token,
  }) async {
    return put('${Constants.petsEndpoint}/$petId', petData, token: token);
  }

  Future<Map<String, dynamic>> deletePet(int petId, {String? token}) async {
    return delete('${Constants.petsEndpoint}/$petId', token: token);
  }
}