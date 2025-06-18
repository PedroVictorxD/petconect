import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../widgets/custom_button.dart';
import '../../theme/app_theme.dart';
import '../../utils/routes.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _featuresController;
  late AnimationController _floatingController;
  late ScrollController _scrollController;

  late Animation<double> _heroFadeAnimation;
  late Animation<Offset> _heroSlideAnimation;
  late Animation<double> _heroScaleAnimation;
  late Animation<double> _featuresAnimation;
  late Animation<double> _floatingAnimation;

  bool _showNavBarBackground = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupScrollListener();
  }

  void _setupAnimations() {
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _featuresController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _heroFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _heroSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _heroScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
    ));

    _featuresAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _featuresController,
      curve: Curves.easeOutCubic,
    ));

    _floatingAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _heroController.forward();
    _floatingController.repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _featuresController.forward();
    });
  }

  void _setupScrollListener() {
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final shouldShow = _scrollController.offset > 100;
      if (shouldShow != _showNavBarBackground) {
        setState(() {
          _showNavBarBackground = shouldShow;
        });
      }
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _featuresController.dispose();
    _floatingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildModernAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildAnimatedHeroSection(context, isDesktop),
                _buildFloatingFeaturesSection(context, isDesktop),
                _buildStatisticsSection(context, isDesktop),
                _buildInteractiveUserTypesSection(context, isDesktop),
                _buildTestimonialsSection(context, isDesktop),
                _buildDynamicCTASection(context),
                _buildModernFooter(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 0,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _showNavBarBackground
                    ? [
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.8),
                      ]
                    : [
                        AppTheme.primaryColor.withOpacity(0.1),
                        Colors.transparent,
                      ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: _showNavBarBackground
                      ? Colors.grey.withOpacity(0.2)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ),
      title: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.pets,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Pet System',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: _showNavBarBackground
                    ? AppTheme.primaryColor
                    : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: CustomButton(
              text: 'Acessar Sistema',
              type: _showNavBarBackground
                  ? ButtonType.primary
                  : ButtonType.secondary,
              onPressed: () => context.go(Routes.login),
              height: 40,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedHeroSection(BuildContext context, bool isDesktop) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    
    return Container(
      height: isMobile ? MediaQuery.of(context).size.height * 0.9 : MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
            AppTheme.primaryColor.withOpacity(0.6),
          ],
        ),
      ),
      child: Stack(
        children: [
          _buildFloatingParticles(),
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20),
              child: FadeTransition(
                opacity: _heroFadeAnimation,
                child: SlideTransition(
                  position: _heroSlideAnimation,
                  child: isDesktop
                      ? Row(
                          children: [
                            Expanded(
                              flex: 6,
                              child: _buildHeroContent(context),
                            ),
                            SizedBox(width: isMobile ? 40 : 80),
                            Expanded(
                              flex: 5,
                              child: ScaleTransition(
                                scale: _heroScaleAnimation,
                                child: _buildAnimatedHeroImage(),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildHeroContent(context),
                            SizedBox(height: isMobile ? 30 : 60),
                            ScaleTransition(
                              scale: _heroScaleAnimation,
                              child: _buildAnimatedHeroImage(),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            return Positioned(
              left: (index * 150.0) % MediaQuery.of(context).size.width,
              top: (index * 80.0) % MediaQuery.of(context).size.height +
                  _floatingAnimation.value,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildHeroContent(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16, 
            vertical: isMobile ? 6 : 8
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Text(
            '🚀 Nova experiência para pets',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 12 : 14,
            ),
          ),
        ),
        SizedBox(height: isMobile ? 16 : 24),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.white, Colors.white.withOpacity(0.8)],
          ).createShader(bounds),
          child: Text(
            'Conectando o\nmundo Pet',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 32 : 56,
              height: 1.1,
            ),
          ),
        ),
        SizedBox(height: isMobile ? 16 : 24),
        Text(
          'A plataforma mais completa que conecta tutores, veterinários e lojistas em um ecossistema único. Gerencie seus pets, encontre produtos de qualidade e acesse serviços especializados.',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white.withOpacity(0.9),
            height: 1.6,
            fontWeight: FontWeight.w400,
            fontSize: isMobile ? 16 : null,
          ),
        ),
        SizedBox(height: isMobile ? 24 : 40),
        isMobile
            ? Column(
                children: [
                  _buildAnimatedButton(
                    text: 'Começar Agora',
                    isPrimary: true,
                    onPressed: () => context.go(Routes.register),
                    icon: Icons.rocket_launch,
                  ),
                  SizedBox(height: 12),
                  _buildAnimatedButton(
                    text: 'Ver Demo',
                    isPrimary: false,
                    onPressed: () => context.go(Routes.login),
                    icon: Icons.play_circle_outline,
                  ),
                ],
              )
            : Row(
                children: [
                  _buildAnimatedButton(
                    text: 'Começar Agora',
                    isPrimary: true,
                    onPressed: () => context.go(Routes.register),
                    icon: Icons.rocket_launch,
                  ),
                  const SizedBox(width: 16),
                  _buildAnimatedButton(
                    text: 'Ver Demo',
                    isPrimary: false,
                    onPressed: () => context.go(Routes.login),
                    icon: Icons.play_circle_outline,
                  ),
                ],
              ),
        SizedBox(height: isMobile ? 24 : 40),
        isMobile
            ? Column(
                children: [
                  _buildTrustItem('10k+', 'Usuários ativos'),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTrustItem('500+', 'Lojistas parceiros'),
                      SizedBox(width: 32),
                      _buildTrustItem('50+', 'Veterinários'),
                    ],
                  ),
                ],
              )
            : _buildTrustIndicators(),
      ],
    );
  }

  Widget _buildAnimatedButton({
    required String text,
    required bool isPrimary,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (isPrimary)
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24, 
              vertical: isMobile ? 12 : 16
            ),
            decoration: BoxDecoration(
              color: isPrimary
                  ? Colors.white
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isPrimary ? AppTheme.primaryColor : Colors.white,
                  size: isMobile ? 16 : 20,
                ),
                SizedBox(width: isMobile ? 6 : 8),
                Text(
                  text,
                  style: TextStyle(
                    color: isPrimary ? AppTheme.primaryColor : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrustIndicators() {
    return Row(
      children: [
        _buildTrustItem('10k+', 'Usuários ativos'),
        const SizedBox(width: 32),
        _buildTrustItem('500+', 'Lojistas parceiros'),
        const SizedBox(width: 32),
        _buildTrustItem('50+', 'Veterinários'),
      ],
    );
  }

  Widget _buildTrustItem(String number, String label) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 18 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: isMobile ? 10 : 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedHeroImage() {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value * 0.5),
          child: Container(
            height: isMobile ? 250 : 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Center(
                  child: Icon(
                    Icons.pets,
                    size: isMobile ? 80 : 120,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingFeaturesSection(BuildContext context, bool isDesktop) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 120, 
        horizontal: isMobile ? 16 : 20
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              FadeTransition(
                opacity: _featuresAnimation,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 16, 
                        vertical: isMobile ? 6 : 8
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'RECURSOS PRINCIPAIS',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 10 : 12,
                        ),
                      ),
                    ),
                    SizedBox(height: isMobile ? 12 : 16),
                    Text(
                      'Tudo que você precisa\npara cuidar melhor do seu pet',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        fontSize: isMobile ? 20 : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isMobile ? 12 : 16),
                    Text(
                      'Ferramentas modernas e intuitivas para uma experiência completa',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                        fontSize: isMobile ? 14 : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 40 : 80),
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(_featuresAnimation),
                child: isDesktop
                    ? Row(
                        children: [
                          Expanded(
                              child: _buildFeatureCard(
                                  context,
                                  Icons.calculate,
                                  'Calculadora Inteligente',
                                  'IA que calcula a quantidade ideal de ração baseada no peso, idade e atividade do seu pet',
                                  0)),
                          const SizedBox(width: 30),
                          Expanded(
                              child: _buildFeatureCard(
                                  context,
                                  Icons.store,
                                  'Marketplace Premium',
                                  'Encontre produtos e serviços verificados na sua região com entrega rápida',
                                  1)),
                          const SizedBox(width: 30),
                          Expanded(
                              child: _buildFeatureCard(
                                  context,
                                  Icons.medical_services,
                                  'Telemedicina Veterinária',
                                  'Conecte-se com veterinários certificados para consultas online e presenciais',
                                  2)),
                        ],
                      )
                    : Column(
                        children: [
                          _buildFeatureCard(
                              context,
                              Icons.calculate,
                              'Calculadora Inteligente',
                              'IA que calcula a quantidade ideal de ração baseada no peso, idade e atividade do seu pet',
                              0),
                          SizedBox(height: isMobile ? 20 : 30),
                          _buildFeatureCard(
                              context,
                              Icons.store,
                              'Marketplace Premium',
                              'Encontre produtos e serviços verificados na sua região com entrega rápida',
                              1),
                          SizedBox(height: isMobile ? 20 : 30),
                          _buildFeatureCard(
                              context,
                              Icons.medical_services,
                              'Telemedicina Veterinária',
                              'Conecte-se com veterinários certificados para consultas online e presenciais',
                              2),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String title,
      String description, int index) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value * (index % 2 == 0 ? 1 : -1) * 0.3),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey[50]!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {},
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 24 : 40),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isMobile ? 16 : 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.1),
                              AppTheme.primaryColor.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          icon,
                          size: isMobile ? 32 : 40,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(height: isMobile ? 16 : 24),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 18 : null,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                          height: 1.6,
                          fontSize: isMobile ? 14 : null,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatisticsSection(BuildContext context, bool isDesktop) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 40 : 80, 
        horizontal: isMobile ? 16 : 20
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: isDesktop
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('50k+', 'Pets Cadastrados', Icons.pets),
                    _buildStatItem('15k+', 'Consultas Realizadas', Icons.medical_services),
                    _buildStatItem('200+', 'Cidades Atendidas', Icons.location_city),
                    _buildStatItem('98%', 'Satisfação', Icons.star),
                  ],
                )
              : Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildStatItem('50k+', 'Pets Cadastrados', Icons.pets)),
                        SizedBox(width: isMobile ? 12 : 20),
                        Expanded(child: _buildStatItem('15k+', 'Consultas Realizadas', Icons.medical_services)),
                      ],
                    ),
                    SizedBox(height: isMobile ? 16 : 30),
                    Row(
                      children: [
                        Expanded(child: _buildStatItem('200+', 'Cidades Atendidas', Icons.location_city)),
                        SizedBox(width: isMobile ? 12 : 20),
                        Expanded(child: _buildStatItem('98%', 'Satisfação', Icons.star)),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String number, String label, IconData icon) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: isMobile ? 24 : 32,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            number,
            style: TextStyle(
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              fontSize: isMobile ? 12 : null,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveUserTypesSection(BuildContext context, bool isDesktop) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 120, 
        horizontal: isMobile ? 16 : 20
      ),
      color: Colors.grey[50],
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'Para Todos os Perfis',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 24 : null,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 12 : 16),
              Text(
                'Soluções personalizadas para cada tipo de usuário',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                  fontSize: isMobile ? 14 : null,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 40 : 80),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
                crossAxisSpacing: isMobile ? 16 : 20,
                mainAxisSpacing: isMobile ? 16 : 20,
                childAspectRatio: isDesktop ? 1.1 : (isTablet ? 1.2 : 1.5),
                children: [
                  _buildInteractiveUserTypeCard(
                      context,
                      Icons.pets,
                      'Tutores',
                      'Gerencie seus pets e encontre os melhores produtos',
                      AppTheme.getUserTypeColor('tutor')),
                  _buildInteractiveUserTypeCard(
                      context,
                      Icons.store,
                      'Lojistas',
                      'Venda produtos e alcance milhares de clientes',
                      AppTheme.getUserTypeColor('lojista')),
                  _buildInteractiveUserTypeCard(
                      context,
                      Icons.medical_services,
                      'Veterinários',
                      'Ofereça consultas e serviços especializados',
                      AppTheme.getUserTypeColor('veterinario')),
                  _buildInteractiveUserTypeCard(
                      context,
                      Icons.admin_panel_settings,
                      'Administradores',
                      'Gerencie toda a plataforma com ferramentas avançadas',
                      AppTheme.getUserTypeColor('admin')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveUserTypeCard(
      BuildContext context, IconData icon, String title, String description, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.all(ResponsiveBreakpoints.of(context).isMobile ? 16 : 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveBreakpoints.of(context).isMobile ? 12 : 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.1),
                        color.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    size: ResponsiveBreakpoints.of(context).isMobile ? 24 : 32,
                    color: color,
                  ),
                ),
                SizedBox(height: ResponsiveBreakpoints.of(context).isMobile ? 12 : 20),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveBreakpoints.of(context).isMobile ? 16 : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveBreakpoints.of(context).isMobile ? 8 : 12),
                Expanded(
                  child: Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      height: 1.4,
                      fontSize: ResponsiveBreakpoints.of(context).isMobile ? 12 : null,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestimonialsSection(BuildContext context, bool isDesktop) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 120, 
        horizontal: isMobile ? 16 : 20
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'O que nossos usuários dizem',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 20 : null,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 12 : 16),
              Text(
                'Milhares de pessoas já confiam no Pet System',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                  fontSize: isMobile ? 14 : null,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 40 : 80),
              isDesktop
                  ? Row(
                      children: [
                        Expanded(child: _buildTestimonialCard(
                          'Ana Silva',
                          'Tutora de 2 pets',
                          'O Pet System revolucionou como cuido dos meus pets. A calculadora de ração é incrível!',
                          '⭐⭐⭐⭐⭐',
                        )),
                        const SizedBox(width: 30),
                        Expanded(child: _buildTestimonialCard(
                          'Dr. Carlos Mendes',
                          'Veterinário',
                          'Plataforma profissional que me conecta com mais clientes. Interface excelente!',
                          '⭐⭐⭐⭐⭐',
                        )),
                        const SizedBox(width: 30),
                        Expanded(child: _buildTestimonialCard(
                          'Maria Lopes',
                          'Proprietária Pet Shop',
                          'Aumentei minhas vendas em 300% desde que comecei a usar o Pet System.',
                          '⭐⭐⭐⭐⭐',
                        )),
                      ],
                    )
                  : Column(
                      children: [
                        _buildTestimonialCard(
                          'Ana Silva',
                          'Tutora de 2 pets',
                          'O Pet System revolucionou como cuido dos meus pets. A calculadora de ração é incrível!',
                          '⭐⭐⭐⭐⭐',
                        ),
                        SizedBox(height: isMobile ? 20 : 30),
                        _buildTestimonialCard(
                          'Dr. Carlos Mendes',
                          'Veterinário',
                          'Plataforma profissional que me conecta com mais clientes. Interface excelente!',
                          '⭐⭐⭐⭐⭐',
                        ),
                        SizedBox(height: isMobile ? 20 : 30),
                        _buildTestimonialCard(
                          'Maria Lopes',
                          'Proprietária Pet Shop',
                          'Aumentei minhas vendas em 300% desde que comecei a usar o Pet System.',
                          '⭐⭐⭐⭐⭐',
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestimonialCard(String name, String role, String testimonial, String rating) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            rating,
            style: TextStyle(fontSize: isMobile ? 20 : 24),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          Text(
            '"$testimonial"',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.6,
              color: Colors.grey[700],
              fontSize: isMobile ? 14 : null,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 16 : 24),
          Container(
            width: isMobile ? 50 : 60,
            height: isMobile ? 50 : 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.2),
                  AppTheme.primaryColor.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: AppTheme.primaryColor,
              size: isMobile ? 25 : 30,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 16 : null,
            ),
          ),
          SizedBox(height: isMobile ? 2 : 4),
          Text(
            role,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              fontSize: isMobile ? 12 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicCTASection(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 120, 
        horizontal: isMobile ? 16 : 20
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
            AppTheme.secondaryColor ?? AppTheme.primaryColor.withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16, 
                  vertical: isMobile ? 6 : 8
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  '🎉 OFERTA ESPECIAL',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 10 : 12,
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 16 : 24),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.white, Colors.white.withOpacity(0.8)],
                ).createShader(bounds),
                child: Text(
                  'Pronto para revolucionar\no cuidado do seu pet?',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    fontSize: isMobile ? 24 : null,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: isMobile ? 16 : 24),
              Text(
                'Junte-se a mais de 50.000 usuários que já transformaram a experiência de cuidar dos seus pets. Comece gratuitamente hoje!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  height: 1.6,
                  fontSize: isMobile ? 16 : null,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 32 : 48),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.go(Routes.register),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 24 : 40, 
                        vertical: isMobile ? 16 : 20
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.rocket_launch,
                            color: AppTheme.primaryColor,
                            size: isMobile ? 20 : 24,
                          ),
                          SizedBox(width: isMobile ? 8 : 12),
                          Text(
                            'Criar Conta Gratuita',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: isMobile ? 16 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 16 : 24),
              Text(
                '✓ Grátis para sempre  ✓ Sem cartão de crédito  ✓ Configuração em 2 minutos',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: isMobile ? 12 : 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernFooter(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 40 : 80, 
        horizontal: isMobile ? 16 : 20
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[900]!,
            Colors.black,
          ],
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(isMobile ? 8 : 12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.pets,
                      color: AppTheme.primaryColor,
                      size: isMobile ? 24 : 32,
                    ),
                  ),
                  SizedBox(width: isMobile ? 12 : 16),
                  Text(
                    'Pet System',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 20 : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 16 : 24),
              Text(
                'A plataforma mais completa para o universo pet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[400],
                  fontSize: isMobile ? 14 : null,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 32 : 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(Icons.facebook, () {}),
                  SizedBox(width: isMobile ? 12 : 16),
                  _buildSocialButton(Icons.camera_alt, () {}),
                  SizedBox(width: isMobile ? 12 : 16),
                  _buildSocialButton(Icons.telegram, () {}),
                  SizedBox(width: isMobile ? 12 : 16),
                  _buildSocialButton(Icons.email, () {}),
                ],
              ),
              SizedBox(height: isMobile ? 32 : 48),
              Container(
                height: 1,
                color: Colors.grey[800],
              ),
              SizedBox(height: isMobile ? 20 : 32),
              isMobile
                  ? Column(
                      children: [
                        Text(
                          '© 2024 Pet System. Todos os direitos reservados.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'Privacidade',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'Termos',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '© 2024 Pet System. Todos os direitos reservados.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'Privacidade',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'Termos',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, VoidCallback onPressed) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(isMobile ? 20 : 25),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 10 : 12),
            child: Icon(
              icon,
              color: Colors.grey[400],
              size: isMobile ? 16 : 20,
            ),
          ),
        ),
      ),
    );
  }
}