import 'constants.dart';

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    
    if (value.length < Constants.minPasswordLength) {
      return 'Senha deve ter pelo menos ${Constants.minPasswordLength} caracteres';
    }
    
    if (value.length > Constants.maxPasswordLength) {
      return 'Senha deve ter no máximo ${Constants.maxPasswordLength} caracteres';
    }
    
    // Pelo menos uma letra maiúscula
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Senha deve conter pelo menos uma letra maiúscula';
    }
    
    // Pelo menos uma letra minúscula
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Senha deve conter pelo menos uma letra minúscula';
    }
    
    // Pelo menos um número
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Senha deve conter pelo menos um número';
    }
    
    // Pelo menos um caractere especial
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Senha deve conter pelo menos um caractere especial';
    }
    
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }
    
    if (value != password) {
      return 'As senhas não coincidem';
    }
    
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome é obrigatório';
    }
    
    if (value.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    
    if (value.length > Constants.maxNameLength) {
      return 'Nome deve ter no máximo ${Constants.maxNameLength} caracteres';
    }
    
    return null;
  }

  static String? validateCNPJ(String? value) {
    if (value == null || value.isEmpty) {
      return null; // CNPJ pode ser opcional em alguns casos
    }
    
    // Remove formatação
    String cnpj = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cnpj.length != 14) {
      return 'CNPJ deve ter 14 dígitos';
    }
    
    // Validação básica do CNPJ
    if (!_isValidCNPJ(cnpj)) {
      return 'CNPJ inválido';
    }
    
    return null;
  }

  static String? validateCRMV(String? value) {
    if (value == null || value.isEmpty) {
      return 'CRMV é obrigatório';
    }
    
    // Remove formatação
    String crmv = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (crmv.length < 4 || crmv.length > 10) {
      return 'CRMV deve ter entre 4 e 10 dígitos';
    }
    
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefone é obrigatório';
    }
    
    // Remove formatação
    String phone = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (phone.length < 10 || phone.length > 11) {
      return 'Telefone deve ter 10 ou 11 dígitos';
    }
    
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Preço é obrigatório';
    }
    
    final price = double.tryParse(value.replaceAll(',', '.'));
    if (price == null || price <= 0) {
      return 'Preço deve ser um valor válido maior que zero';
    }
    
    return null;
  }

  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Peso é obrigatório';
    }
    
    final weight = double.tryParse(value.replaceAll(',', '.'));
    if (weight == null || weight <= 0) {
      return 'Peso deve ser um valor válido maior que zero';
    }
    
    return null;
  }

  static String? validateDescription(String? value) {
    if (value != null && value.length > Constants.maxDescriptionLength) {
      return 'Descrição deve ter no máximo ${Constants.maxDescriptionLength} caracteres';
    }
    return null;
  }

  // Validação de CNPJ mais robusta
  static bool _isValidCNPJ(String cnpj) {
    if (cnpj.length != 14) return false;
    
    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1*$').hasMatch(cnpj)) return false;
    
    // Calcula o primeiro dígito verificador
    int sum = 0;
    List<int> weights = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    
    for (int i = 0; i < 12; i++) {
      sum += int.parse(cnpj[i]) * weights[i];
    }
    
    int remainder = sum % 11;
    int digit1 = remainder < 2 ? 0 : 11 - remainder;
    
    if (digit1 != int.parse(cnpj[12])) return false;
    
    // Calcula o segundo dígito verificador
    sum = 0;
    weights = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    
    for (int i = 0; i < 13; i++) {
      sum += int.parse(cnpj[i]) * weights[i];
    }
    
    remainder = sum % 11;
    int digit2 = remainder < 2 ? 0 : 11 - remainder;
    
    return digit2 == int.parse(cnpj[13]);
  }
}