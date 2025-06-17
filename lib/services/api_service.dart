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
        'error': Constants.networkErrorMessage,
      };
    } else if (error is http.ClientException) {
      return {
        'success': false,
        'error': 'Erro de conexão com o servidor',
      };
    } else {
      return {
        'success': false,
        'error': Constants.genericErrorMessage,
      };
    }
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