import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../services/auth_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../theme/app_theme.dart';
import '../../utils/routes.dart';
import '../../utils/validators.dart';
import '../../utils/constants.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  
  // Controllers básicos
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Controllers específicos
  final _cnpjController = TextEditingController();
  final _crmvController = TextEditingController();
  final _responsibleNameController = TextEditingController();
  final _operatingHoursController = TextEditingController();
  
  // Perguntas de segurança
  final _securityAnswer1Controller = TextEditingController();
  final _securityAnswer2Controller = TextEditingController();
  final _securityAnswer3Controller = TextEditingController();
  
  String _selectedUserType = Constants.tutorType;
  String _selectedStoreType = Constants.physicalStore;
  String _selectedSecurityQuestion1 = Constants.securityQuestions[0];
  String _selectedSecurityQuestion2 = Constants.securityQuestions[1];
  String _selectedSecurityQuestion3 = Constants.securityQuestions[2];
  
  int _currentStep = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _cnpjController.dispose();
    _crmvController.dispose();
    _responsibleNameController.dispose();
    _operatingHoursController.dispose();
    _securityAnswer1Controller.dispose();
    _securityAnswer2Controller.dispose();
    _securityAnswer3Controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.login),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Indicador de progresso
            _buildProgressIndicator(),
            
            // Conteúdo das etapas
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(), // Tipo de usuário
                  _buildStep2(), // Dados básicos
                  _buildStep3(), // Dados específicos
                  _buildStep4(), // Perguntas de segurança
                ],
              ),
            ),
            
            // Botões de navegação
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive 
                          ? AppTheme.primaryColor 
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.primaryColor
                        : isActive
                            ? AppTheme.primaryColor
                            : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tipo de Usuário',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecione o tipo de conta que deseja criar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          // Cards de seleção de tipo de usuário
          _buildUserTypeCard(
            Constants.tutorType,
            'Tutor',
            'Para donos de pets que desejam gerenciar seus animais',
            Icons.pets,
            AppTheme.getUserTypeColor('tutor'),
          ),
          const SizedBox(height: 16),
          _buildUserTypeCard(
            Constants.lojistaType,
            'Lojista',
            'Para donos de lojas que vendem produtos para pets',
            Icons.store,
            AppTheme.getUserTypeColor('lojista'),
          ),
          const SizedBox(height: 16),
          _buildUserTypeCard(
            Constants.veterinarioType,
            'Veterinário',
            'Para profissionais veterinários que oferecem serviços',
            Icons.medical_services,
            AppTheme.getUserTypeColor('veterinario'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeCard(String type, String title, String description, IconData icon, Color color) {
    final isSelected = _selectedUserType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUserType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? color.withOpacity(0.05) : null,
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dados Básicos',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Preencha suas informações pessoais',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          CustomTextField(
            label: 'Nome Completo',
            controller: _nameController,
            validator: Validators.validateName,
            required: true,
          ),
          const SizedBox(height: 16),
          
          EmailField(
            controller: _emailController,
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 16),
          
          PasswordField(
            controller: _passwordController,
            validator: Validators.validatePassword,
          ),
          const SizedBox(height: 16),
          
          PasswordField(
            labelText: 'Confirmar Senha',
            hintText: 'Digite a senha novamente',
            controller: _confirmPasswordController,
            validator: (value) => Validators.validateConfirmPassword(
              value,
              _passwordController.text,
            ),
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            label: 'Localização',
            controller: _locationController,
            validator: (value) => Validators.validateRequired(value, 'Localização'),
            hint: 'Cidade, Estado',
            prefixIcon: const Icon(Icons.location_on),
            required: true,
          ),
          const SizedBox(height: 16),
          
          PhoneField(
            controller: _phoneController,
            validator: Validators.validatePhone,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dados Específicos',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Informações específicas para ${_getUserTypeLabel(_selectedUserType)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          // Campos específicos baseados no tipo de usuário
          if (_selectedUserType == Constants.lojistaType) ..._buildLojistaFields(),
          if (_selectedUserType == Constants.veterinarioType) ..._buildVeterinarioFields(),
          if (_selectedUserType == Constants.tutorType) ..._buildTutorFields(),
        ],
      ),
    );
  }

  List<Widget> _buildLojistaFields() {
    return [
      CNPJField(
        controller: _cnpjController,
        validator: Validators.validateCNPJ,
        required: true,
      ),
      const SizedBox(height: 16),
      
      // Tipo de loja
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tipo de Loja *',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Física'),
                  value: Constants.physicalStore,
                  groupValue: _selectedStoreType,
                  onChanged: (value) {
                    setState(() {
                      _selectedStoreType = value!;
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Virtual'),
                  value: Constants.virtualStore,
                  groupValue: _selectedStoreType,
                  onChanged: (value) {
                    setState(() {
                      _selectedStoreType = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildVeterinarioFields() {
    return [
      CRMVField(
        controller: _crmvController,
        validator: Validators.validateCRMV,
      ),
      const SizedBox(height: 16),
      
      CustomTextField(
        label: 'Horários de Funcionamento',
        controller: _operatingHoursController,
        hint: 'Ex: Segunda a Sexta, 8h às 18h',
        prefixIcon: const Icon(Icons.access_time),
        maxLines: 2,
      ),
    ];
  }

  List<Widget> _buildTutorFields() {
    return [
      CNPJField(
        controller: _cnpjController,
        validator: (value) => null, // CNPJ opcional para tutores
        required: false,
      ),
      const SizedBox(height: 16),
      
      CustomTextField(
        label: 'Nome do Responsável',
        controller: _responsibleNameController,
        hint: 'Nome de quem é responsável pelos pets',
        prefixIcon: const Icon(Icons.person),
      ),
    ];
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Perguntas de Segurança',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure 3 perguntas de segurança para recuperação de senha',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          // Pergunta 1
          _buildSecurityQuestionField(
            1,
            _selectedSecurityQuestion1,
            _securityAnswer1Controller,
            (value) {
              setState(() {
                _selectedSecurityQuestion1 = value!;
              });
            },
          ),
          const SizedBox(height: 20),
          
          // Pergunta 2
          _buildSecurityQuestionField(
            2,
            _selectedSecurityQuestion2,
            _securityAnswer2Controller,
            (value) {
              setState(() {
                _selectedSecurityQuestion2 = value!;
              });
            },
          ),
          const SizedBox(height: 20),
          
          // Pergunta 3
          _buildSecurityQuestionField(
            3,
            _selectedSecurityQuestion3,
            _securityAnswer3Controller,
            (value) {
              setState(() {
                _selectedSecurityQuestion3 = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityQuestionField(
    int number,
    String selectedQuestion,
    TextEditingController controller,
    void Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pergunta $number *',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedQuestion,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.help),
          ),
          items: Constants.securityQuestions.map((question) {
            return DropdownMenuItem(
              value: question,
              child: Text(question),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Selecione uma pergunta';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: 'Resposta $number',
          controller: controller,
          validator: (value) => Validators.validateRequired(value, 'Resposta'),
          hint: 'Digite sua resposta',
          prefixIcon: const Icon(Icons.edit),
          required: true,
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: CustomButton(
                text: 'Anterior',
                type: ButtonType.outlined,
                onPressed: _previousStep,
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: CustomButton(
              text: _currentStep == 3 ? 'Criar Conta' : 'Próximo',
              onPressed: _isLoading ? null : _nextStep,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      if (_validateCurrentStep()) {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _handleRegister();
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _selectedUserType.isNotEmpty;
      case 1:
        return _nameController.text.isNotEmpty &&
               _emailController.text.isNotEmpty &&
               _passwordController.text.isNotEmpty &&
               _confirmPasswordController.text.isNotEmpty &&
               _locationController.text.isNotEmpty &&
               _phoneController.text.isNotEmpty &&
               Validators.validateEmail(_emailController.text) == null &&
               Validators.validatePassword(_passwordController.text) == null &&
               Validators.validateConfirmPassword(
                 _confirmPasswordController.text,
                 _passwordController.text,
               ) == null;
      case 2:
        if (_selectedUserType == Constants.lojistaType) {
          return Validators.validateCNPJ(_cnpjController.text) == null;
        } else if (_selectedUserType == Constants.veterinarioType) {
          return Validators.validateCRMV(_crmvController.text) == null;
        }
        return true;
      case 3:
        return _securityAnswer1Controller.text.isNotEmpty &&
               _securityAnswer2Controller.text.isNotEmpty &&
               _securityAnswer3Controller.text.isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final userData = _buildUserData();
      
      final success = await authService.register(userData);

      if (success && mounted) {
        await SuccessDialog.show(
          context,
          message: 'Conta criada com sucesso! Você pode fazer login agora.',
        );
        
        context.go(Routes.login);
      } else if (mounted) {
        await ErrorDialog.show(
          context,
          message: 'Erro ao criar conta. Verifique os dados e tente novamente.',
        );
      }
    } catch (e) {
      if (mounted) {
        await ErrorDialog.show(
          context,
          message: 'Erro ao criar conta. Verifique sua conexão e tente novamente.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _buildUserData() {
    final data = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'userType': _selectedUserType,
      'location': _locationController.text.trim(),
      'phone': _phoneController.text.replaceAll(RegExp(r'[^\d]'), ''),
      'securityQuestions': [
        {
          'question': _selectedSecurityQuestion1,
          'answer': _securityAnswer1Controller.text.trim(),
        },
        {
          'question': _selectedSecurityQuestion2,
          'answer': _securityAnswer2Controller.text.trim(),
        },
        {
          'question': _selectedSecurityQuestion3,
          'answer': _securityAnswer3Controller.text.trim(),
        },
      ],
    };

    // Adicionar dados específicos baseados no tipo de usuário
    if (_selectedUserType == Constants.lojistaType) {
      data['cnpj'] = _cnpjController.text.replaceAll(RegExp(r'[^\d]'), '');
      data['storeType'] = _selectedStoreType;
    } else if (_selectedUserType == Constants.veterinarioType) {
      data['crmv'] = _crmvController.text.replaceAll(RegExp(r'[^\d]'), '');
      if (_operatingHoursController.text.isNotEmpty) {
        data['operatingHours'] = _operatingHoursController.text.trim();
      }
    } else if (_selectedUserType == Constants.tutorType) {
      if (_cnpjController.text.isNotEmpty) {
        data['cnpj'] = _cnpjController.text.replaceAll(RegExp(r'[^\d]'), '');
      }
      if (_responsibleNameController.text.isNotEmpty) {
        data['responsibleName'] = _responsibleNameController.text.trim();
      }
    }

    return data;
  }

  String _getUserTypeLabel(String userType) {
    switch (userType) {
      case Constants.tutorType:
        return 'Tutor';
      case Constants.lojistaType:
        return 'Lojista';
      case Constants.veterinarioType:
        return 'Veterinário';
      default:
        return userType;
    }
  }
}