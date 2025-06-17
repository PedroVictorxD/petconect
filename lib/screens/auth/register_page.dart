import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int _currentStep = 0;
  bool _isLoading = false;
  String _selectedUserType = Constants.tutorType;
  String _selectedStoreType = 'FISICA';
  
  // Chave do formulário para validação
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _responsibleNameController = TextEditingController();
  final _operatingHoursController = TextEditingController();
  final _crmvController = TextEditingController();

  final List<Map<String, String>> _steps = [
    {
      'title': 'Dados Básicos',
      'subtitle': 'Preencha suas informações pessoais',
    },
    {
      'title': 'Tipo de Usuário',
      'subtitle': 'Selecione como você usará a plataforma',
    },
    {
      'title': 'Informações Específicas',
      'subtitle': 'Complete seu perfil',
    },
    {
      'title': 'Confirmação',
      'subtitle': 'Revise seus dados antes de finalizar',
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _cnpjController.dispose();
    _responsibleNameController.dispose();
    _operatingHoursController.dispose();
    _crmvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Criar Conta'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Progress indicator
                  _buildProgressIndicator(),
                  
                  const SizedBox(height: 40),
                  
                  // Título
                  Text(
                    _steps[_currentStep]['title']!,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    _steps[_currentStep]['subtitle']!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Content based on current step
                  _buildStepContent(),
                  
                  const SizedBox(height: 40),
                  
                  // Navigation buttons
                  _buildNavigationButtons(),
                  
                  const SizedBox(height: 24),
                  
                  // Link para login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Já tem uma conta? ',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Fazer Login'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(_steps.length, (index) {
        final isCompleted = index < _currentStep;
        final isCurrent = index == _currentStep;
        
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < _steps.length - 1 ? 8 : 0),
            child: Column(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent ? Colors.green : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green : (isCurrent ? Colors.green : Colors.grey[300]),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isCurrent ? Colors.white : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBasicDataStep();
      case 1:
        return _buildUserTypeStep();
      case 2:
        return _buildSpecificDataStep();
      case 3:
        return _buildConfirmationStep();
      default:
        return Container();
    }
  }

  Widget _buildBasicDataStep() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nome Completo *',
            hintText: 'Digite seu nome completo',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nome é obrigatório';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email *',
            hintText: 'Digite seu email',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email é obrigatório';
            }
            if (!value.contains('@')) {
              return 'Digite um email válido';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Senha *',
            hintText: 'Digite sua senha',
            prefixIcon: Icon(Icons.lock),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Senha é obrigatória';
            }
            if (value.length < 6) {
              return 'Senha deve ter pelo menos 6 caracteres';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Confirmar Senha *',
            hintText: 'Digite a senha novamente',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Confirmação de senha é obrigatória';
            }
            if (value != _passwordController.text) {
              return 'Senhas não coincidem';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'Localização *',
            hintText: 'Cidade, Estado',
            prefixIcon: Icon(Icons.location_on),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Localização é obrigatória';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Telefone *',
            hintText: '(XX) XXXXX-XXXX',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Telefone é obrigatório';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildUserTypeStep() {
    return Column(
      children: [
        _buildUserTypeCard(
          Constants.tutorType,
          'Tutor de Pet',
          'Encontre produtos, serviços e cuidados para seu pet',
          Icons.pets,
          Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildUserTypeCard(
          Constants.lojistaType,
          'Lojista',
          'Venda produtos e serviços para pets',
          Icons.store,
          Colors.orange,
        ),
        const SizedBox(height: 16),
        _buildUserTypeCard(
          Constants.veterinarioType,
          'Veterinário',
          'Ofereça serviços veterinários e consultas',
          Icons.medical_services,
          Colors.green,
        ),
        const SizedBox(height: 16),
        _buildUserTypeCard(
          Constants.adminType,
          'Administrador',
          'Gerencie a plataforma e usuários',
          Icons.admin_panel_settings,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildUserTypeCard(String type, String title, String description, IconData icon, Color color) {
    final isSelected = _selectedUserType == type;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedUserType = type;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected ? color : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificDataStep() {
    if (_selectedUserType == Constants.lojistaType) {
      return Column(
        children: [
          TextFormField(
            controller: _cnpjController,
            decoration: const InputDecoration(
              labelText: 'CNPJ',
              hintText: 'XX.XXX.XXX/XXXX-XX',
              prefixIcon: Icon(Icons.business),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _responsibleNameController,
            decoration: const InputDecoration(
              labelText: 'Nome do Responsável',
              hintText: 'Nome completo do responsável',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _operatingHoursController,
            decoration: const InputDecoration(
              labelText: 'Horário de Funcionamento',
              hintText: 'Ex: 08:00 às 18:00',
              prefixIcon: Icon(Icons.access_time),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      );
    } else if (_selectedUserType == Constants.veterinarioType) {
      return Column(
        children: [
          TextFormField(
            controller: _crmvController,
            decoration: const InputDecoration(
              labelText: 'CRMV',
              hintText: 'Número do registro CRMV',
              prefixIcon: Icon(Icons.badge),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'CRMV é obrigatório para veterinários';
              }
              return null;
            },
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Dados Básicos Completos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Suas informações básicas estão completas. Você pode prosseguir para finalizar o cadastro.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.green[600]),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildConfirmationStep() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Confirme seus dados:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(height: 16),
              _buildConfirmationItem('Nome', _nameController.text),
              _buildConfirmationItem('Email', _emailController.text),
              _buildConfirmationItem('Tipo', _getUserTypeLabel()),
              _buildConfirmationItem('Localização', _locationController.text),
              _buildConfirmationItem('Telefone', _phoneController.text),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value.isEmpty ? 'Não informado' : value),
          ),
        ],
      ),
    );
  }

  String _getUserTypeLabel() {
    switch (_selectedUserType) {
      case Constants.tutorType:
        return 'Tutor de Pet';
      case Constants.lojistaType:
        return 'Lojista';
      case Constants.veterinarioType:
        return 'Veterinário';
      case Constants.adminType:
        return 'Administrador';
      default:
        return 'Não selecionado';
    }
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _currentStep--;
                });
              },
              child: const Text('Anterior'),
            ),
          ),
        
        if (_currentStep > 0) const SizedBox(width: 16),
        
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(_currentStep == _steps.length - 1 ? 'Finalizar Cadastro' : 'Próximo'),
          ),
        ),
      ],
    );
  }

  void _handleNext() {
    // Validar apenas no primeiro step (dados básicos)
    if (_currentStep == 0) {
      if (!_formKey.currentState!.validate()) {
        return; // Não avança se a validação falhar
      }
    }
    
    // Validar CRMV para veterinários no step 2
    if (_currentStep == 2 && _selectedUserType == Constants.veterinarioType) {
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }
    
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Avançou para step ${_currentStep + 1}!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      _handleRegister();
    }
  }

  void _handleRegister() {
    setState(() {
      _isLoading = true;
    });
    
    // Simular registro
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Conta criada com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.go('/login');
          }
        });
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }
}