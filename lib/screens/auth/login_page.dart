import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../services/auth_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/loading_widget.dart';
import '../../theme/app_theme.dart';
import '../../utils/routes.dart';
import '../../utils/validators.dart';
import '../../utils/constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> 
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _errorMessage;
  
  late AnimationController _heroController;
  late AnimationController _formController;
  late AnimationController _floatingController;
  
  late Animation<double> _heroFadeAnimation;
  late Animation<Offset> _heroSlideAnimation;
  late Animation<double> _heroScaleAnimation;
  late Animation<double> _formFadeAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupFocusListeners();
  }

  void _setupAnimations() {
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _formController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Hero animations
    _heroFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _heroSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _heroScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
    ));

    // Form animations
    _formFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    // Floating animation
    _floatingAnimation = Tween<double>(
      begin: -8.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _formController.forward();
    });
    _floatingController.repeat(reverse: true);
  }

  void _setupFocusListeners() {
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _heroController.dispose();
    _formController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: LoadingOverlay(
        isLoading: _isLoading,
        loadingMessage: 'Autenticando...',
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: _buildBackgroundDecoration(),
          child: Stack(
            children: [
              // Floating particles (sem sombras)
              _buildFloatingParticles(),
              
              // Main content
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : (isDesktop ? 40 : 24),
                      vertical: isMobile ? 16 : 20,
                    ),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 500 : double.infinity,
                        minHeight: isMobile ? screenSize.height * 0.8 : screenSize.height * 0.7,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated header
                          SlideTransition(
                            position: _heroSlideAnimation,
                            child: FadeTransition(
                              opacity: _heroFadeAnimation,
                              child: ScaleTransition(
                                scale: _heroScaleAnimation,
                                child: _buildAnimatedHeader(context, isMobile),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: isMobile ? 30 : (isDesktop ? 50 : 40)),
                          
                          // Login form
                          SlideTransition(
                            position: _formSlideAnimation,
                            child: FadeTransition(
                              opacity: _formFadeAnimation,
                              child: _buildCleanLoginForm(context, isDesktop, isMobile),
                            ),
                          ),
                          
                          SizedBox(height: isMobile ? 20 : 24),
                          
                          // Navigation links
                          FadeTransition(
                            opacity: _formFadeAnimation,
                            child: _buildNavigationLinks(context, isMobile),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Back button
              Positioned(
                top: MediaQuery.of(context).padding.top + (isMobile ? 8 : 10),
                left: isMobile ? 12 : 20,
                child: _buildBackButton(context, isMobile),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.primaryColor.withOpacity(0.08),
          Colors.white,
          AppTheme.secondaryColor?.withOpacity(0.05) ?? Colors.blue.withOpacity(0.05),
        ],
        stops: const [0.0, 0.5, 1.0],
      ),
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final random = math.Random(index);
            return Positioned(
              left: random.nextDouble() * MediaQuery.of(context).size.width,
              top: (random.nextDouble() * MediaQuery.of(context).size.height) +
                  (_floatingAnimation.value * (index % 2 == 0 ? 1 : -1)),
              child: Container(
                width: 3 + (random.nextDouble() * 3),
                height: 3 + (random.nextDouble() * 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildBackButton(BuildContext context, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(Routes.landing),
          borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 8 : 12),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: AppTheme.primaryColor,
              size: isMobile ? 16 : 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader(BuildContext context, bool isMobile) {
    return Column(
      children: [
        // Logo simples sem sombras
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.1),
                AppTheme.primaryColor.withOpacity(0.05),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.pets,
            size: isMobile ? 36 : 48,
            color: AppTheme.primaryColor,
          ),
        ),
        
        SizedBox(height: isMobile ? 20 : 32),
        
        // Title with gradient text
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.7),
            ],
          ).createShader(bounds),
          child: Text(
            'Pet Conect',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 24 : null,
            ),
          ),
        ),
        
        SizedBox(height: isMobile ? 8 : 12),
        
        // Welcome text
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 20, 
            vertical: isMobile ? 8 : 10
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.2),
            ),
          ),
          child: Text(
            'Bem-vindo de volta! 🐾',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 14 : null,
            ),
          ),
        ),
        
        SizedBox(height: isMobile ? 6 : 8),
        
        Text(
          'Entre com suas credenciais para acessar sua conta',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
            height: 1.4,
            fontSize: isMobile ? 13 : null,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCleanLoginForm(BuildContext context, bool isDesktop, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white,
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : (isDesktop ? 40 : 32)),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Error message
              if (_errorMessage != null)
                _buildErrorMessage(),
              
              // Email field
              _buildCleanTextField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                label: 'Email',
                hint: 'Digite seu email',
                icon: Icons.email_outlined,
                validator: Validators.validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              
              const SizedBox(height: 24),
              
              // Password field
              _buildCleanTextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                label: 'Senha',
                hint: 'Digite sua senha',
                icon: Icons.lock_outline,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Senha é obrigatória';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Remember me and forgot password
              Row(
                children: [
                  _buildRememberMeCheckbox(),
                  const Spacer(),
                  _buildForgotPasswordLink(),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Login button
              _buildCleanLoginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              color: Colors.red[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool isPassword = false,
  }) {
    final isFocused = focusNode.hasFocus;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.grey[50],
        border: Border.all(
          color: isFocused 
              ? AppTheme.primaryColor
              : Colors.grey.withOpacity(0.3),
          width: isFocused ? 2 : 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        validator: validator,
        keyboardType: keyboardType,
        obscureText: isPassword ? _obscurePassword : false,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: isFocused 
                ? AppTheme.primaryColor
                : AppTheme.primaryColor.withOpacity(0.6),
            size: 22,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          labelStyle: TextStyle(
            color: isFocused ? AppTheme.primaryColor : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: Colors.grey[400],
          ),
        ),
      ),
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _rememberMe 
                  ? AppTheme.primaryColor 
                  : Colors.grey.withOpacity(0.4),
            ),
            color: _rememberMe 
                ? AppTheme.primaryColor 
                : Colors.transparent,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _rememberMe = !_rememberMe;
                });
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                child: _rememberMe
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              _rememberMe = !_rememberMe;
            });
          },
          child: Text(
            'Lembrar de mim',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordLink() {
    return TextButton(
      onPressed: () => context.go(Routes.forgotPassword),
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      child: const Text('Esqueci minha senha'),
    );
  }

  Widget _buildCleanLoginButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: _isLoading
              ? [Colors.grey[400]!, Colors.grey[500]!]
              : [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _handleLogin,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            alignment: Alignment.center,
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.login,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Entrar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationLinks(BuildContext context, bool isMobile) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                'Não tem uma conta? ',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isMobile ? 13 : 15,
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.go(Routes.register),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 2 : 4),
                textStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 13 : 15,
                ),
              ),
              child: const Text('Cadastre-se aqui'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final success = await authService.login(email, password);

      if (success && mounted) {
        // Sucesso - animação de saída
        await _heroController.reverse();
        
        // Redirecionar baseado no tipo de usuário
        final user = authService.currentUser;
        String route = Routes.landing;
        
        if (user != null) {
          switch (user.userType) {
            case Constants.adminType:
              route = Routes.admin;
              break;
            case Constants.lojistaType:
              route = Routes.lojista;
              break;
            case Constants.veterinarioType:
              route = Routes.veterinario;
              break;
            case Constants.tutorType:
            default:
              route = Routes.tutor;
              break;
          }
        }
        
        context.go(route);
        
        // Mostrar mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Text(
                  'Login realizado com sucesso! 🎉',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Email ou senha incorretos. Verifique suas credenciais e tente novamente.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao fazer login. Verifique sua conexão e tente novamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}