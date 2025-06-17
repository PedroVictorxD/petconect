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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo e título
                  _buildHeader(context),
                  
                  const SizedBox(height: 40),
                  
                  // Formulário de login
                  _buildLoginForm(context),
                  
                  const SizedBox(height: 20),
                  
                  // Link para cadastro
                  _buildSignUpLink(context),
                  
                  const SizedBox(height: 20),
                  
                  // Link para voltar à landing page
                  _buildBackToLandingLink(context),
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
            Icons.pets,
            size: 60,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Pet System',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Faça login para acessar sua conta',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
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
              EmailField(
                controller: _emailController,
                validator: Validators.validateEmail,
              ),
              
              const SizedBox(height: 16),
              
              PasswordField(
                controller: _passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Senha é obrigatória';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 8),
              
              // Link "Esqueci minha senha"
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go(Routes.forgotPassword),
                  child: const Text('Esqueci minha senha'),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Botão de login
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Entrar',
                  onPressed: _isLoading ? null : _handleLogin,
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

  Widget _buildSignUpLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Não tem uma conta? ',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () => context.go(Routes.register),
          child: const Text(
            'Cadastre-se aqui',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildBackToLandingLink(BuildContext context) {
    return TextButton.icon(
      onPressed: () => context.go(Routes.landing),
      icon: const Icon(Icons.arrow_back),
      label: const Text('Voltar ao início'),
      style: TextButton.styleFrom(
        foregroundColor: Colors.grey[600],
      ),
    );
  }

  Widget _buildDemoUser(String email, String role, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          _emailController.text = email;
          _passwordController.text = 'demo123'; // Qualquer senha funciona
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      role,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.touch_app,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final success = await authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        // Redirecionar para a homepage apropriada baseada no tipo de usuário
        final route = authService.getHomepageRoute();
        context.go(route);
        
        // Mostrar mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        // Mostrar erro
        await ErrorDialog.show(
          context,
          message: 'Email ou senha incorretos. Verifique suas credenciais e tente novamente.',
        );
      }
    } catch (e) {
      if (mounted) {
        await ErrorDialog.show(
          context,
          message: 'Erro ao fazer login. Verifique sua conexão e tente novamente.',
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