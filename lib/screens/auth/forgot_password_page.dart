import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../theme/app_theme.dart';
import '../../utils/routes.dart';
import '../../utils/validators.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _answerPetController = TextEditingController();
  final _answerCarController = TextEditingController();
  final _answerFriendController = TextEditingController();
  final _newPasswordController = TextEditingController();
  
  String? _securityQuestion;
  bool _isLoading = false;
  bool _questionLoaded = false;

  @override
  void dispose() {
    _emailController.dispose();
    _answerPetController.dispose();
    _answerCarController.dispose();
    _answerFriendController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Senha'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.login),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  // Header
                  _buildHeader(context),
                  
                  const SizedBox(height: 40),
                  
                  // Formulário
                  _buildForm(context),
                  
                  const SizedBox(height: 20),
                  
                  // Link para voltar ao login
                  _buildBackToLoginLink(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(
            Icons.lock_reset,
            size: 60,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Recuperar Senha',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _questionLoaded
              ? 'Responda à pergunta de segurança para redefinir sua senha'
              : 'Digite seu email para buscar sua pergunta de segurança',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo de email
              EmailField(
                controller: _emailController,
                validator: Validators.validateEmail,
                enabled: !_questionLoaded,
              ),
              
              if (!_questionLoaded) ...[
                const SizedBox(height: 24),
                
                // Botão para buscar pergunta de segurança
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Buscar Pergunta de Segurança',
                    onPressed: _isLoading ? null : _loadSecurityQuestion,
                    isLoading: _isLoading,
                    height: 50,
                  ),
                ),
              ],
              
              if (_questionLoaded && _securityQuestion != null) ...[
                const SizedBox(height: 24),
                
                // Pergunta de segurança
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pergunta de Segurança:',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _securityQuestion!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Campo de resposta
                CustomTextField(
                  label: 'Sua Resposta',
                  controller: _answerPetController,
                  validator: (value) => Validators.validateRequired(value, 'Resposta'),
                  hint: 'Digite sua resposta',
                  prefixIcon: const Icon(Icons.edit),
                  required: true,
                ),
                
                const SizedBox(height: 16),
                
                // Botão para confirmar
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Confirmar e Redefinir Senha',
                    onPressed: _isLoading ? null : _handleForgotPassword,
                    isLoading: _isLoading,
                    height: 50,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Botão para tentar com outro email
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Tentar com Outro Email',
                    type: ButtonType.outlined,
                    onPressed: _resetForm,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackToLoginLink(BuildContext context) {
    return TextButton.icon(
      onPressed: () => context.go(Routes.login),
      icon: const Icon(Icons.arrow_back),
      label: const Text('Voltar ao Login'),
      style: TextButton.styleFrom(
        foregroundColor: Colors.grey[600],
      ),
    );
  }

  Future<void> _loadSecurityQuestion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final question = await authService.getSecurityQuestion(_emailController.text.trim());

      if (question != null && mounted) {
        setState(() {
          _securityQuestion = question;
          _questionLoaded = true;
        });
      } else if (mounted) {
        await ErrorDialog.show(
          context,
          message: 'Email não encontrado ou não possui pergunta de segurança cadastrada.',
        );
      }
    } catch (e) {
      if (mounted) {
        await ErrorDialog.show(
          context,
          message: 'Erro ao buscar pergunta de segurança. Tente novamente.',
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

  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final success = await authService.forgotPassword(
        _emailController.text.trim(),
        _answerPetController.text.trim(),
        _answerCarController.text.trim(),
        _answerFriendController.text.trim(),
        _newPasswordController.text.trim(),
      );

      if (success && mounted) {
        await SuccessDialog.show(
          context,
          message: 'Verificação realizada com sucesso! Você será redirecionado para redefinir sua senha.',
        );
        
        // Redirecionar para a página de redefinição de senha
        context.go('${Routes.resetPassword}?email=${_emailController.text.trim()}');
      } else if (mounted) {
        await ErrorDialog.show(
          context,
          message: 'Resposta incorreta. Verifique sua resposta e tente novamente.',
        );
      }
    } catch (e) {
      if (mounted) {
        await ErrorDialog.show(
          context,
          message: 'Erro ao processar solicitação. Tente novamente.',
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

  void _resetForm() {
    setState(() {
      _questionLoaded = false;
      _securityQuestion = null;
      _answerPetController.clear();
      _answerCarController.clear();
      _answerFriendController.clear();
      _newPasswordController.clear();
    });
  }
}