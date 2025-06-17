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

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String? _userEmail;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pegar o email dos parâmetros da URL
    final uri = GoRouterState.of(context).uri;
    _userEmail = uri.queryParameters['email'];
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Redefinir Senha'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.forgotPassword),
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
          'Nova Senha',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Crie uma nova senha segura para sua conta',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        if (_userEmail != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.email, color: Colors.blue[600], size: 16),
                const SizedBox(width: 8),
                Text(
                  _userEmail!,
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
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
              // Requisitos de senha
              _buildPasswordRequirements(context),
              
              const SizedBox(height: 24),
              
              // Nova senha
              PasswordField(
                labelText: 'Nova Senha',
                hintText: 'Digite sua nova senha',
                controller: _newPasswordController,
                validator: Validators.validatePassword,
              ),
              
              const SizedBox(height: 16),
              
              // Confirmar nova senha
              PasswordField(
                labelText: 'Confirmar Nova Senha',
                hintText: 'Digite a senha novamente',
                controller: _confirmPasswordController,
                validator: (value) => Validators.validateConfirmPassword(
                  value,
                  _newPasswordController.text,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Botão para redefinir
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Redefinir Senha',
                  onPressed: _isLoading ? null : _handleResetPassword,
                  isLoading: _isLoading,
                  height: 50,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRequirements(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.amber[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Requisitos da Senha',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.amber[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRequirementItem('Pelo menos 8 caracteres'),
          _buildRequirementItem('Uma letra maiúscula'),
          _buildRequirementItem('Uma letra minúscula'),
          _buildRequirementItem('Um número'),
          _buildRequirementItem('Um caractere especial (!@#\$%^&*)'),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Colors.amber[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.amber[700],
              ),
            ),
          ),
        ],
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

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_userEmail == null) {
      await ErrorDialog.show(
        context,
        message: 'Email não encontrado. Volte à página anterior e tente novamente.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Em um cenário real, você receberia um token de redefinição
      // Por simplicidade, vamos usar um token fictício
      const resetToken = 'temp_reset_token';
      
      final success = await authService.resetPassword(
        _userEmail!,
        _newPasswordController.text,
        resetToken,
      );

      if (success && mounted) {
        await SuccessDialog.show(
          context,
          title: 'Senha Redefinida!',
          message: 'Sua senha foi redefinida com sucesso. Você pode fazer login agora.',
        );
        
        context.go(Routes.login);
      } else if (mounted) {
        await ErrorDialog.show(
          context,
          message: 'Erro ao redefinir senha. Tente novamente.',
        );
      }
    } catch (e) {
      if (mounted) {
        await ErrorDialog.show(
          context,
          message: 'Erro ao redefinir senha. Verifique sua conexão e tente novamente.',
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
}