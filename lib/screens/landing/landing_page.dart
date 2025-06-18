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
    return Container(
      height: MediaQuery.of(context).size.height,
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                            const SizedBox(width: 80),
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
                            const SizedBox(height: 60),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.white, Colors.white.withOpacity(0.8)],
          ).createShader(bounds),
          child: Text(
            'Conectando o\nmundo Pet',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 56,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'A plataforma mais completa que conecta tutores, veterinários e lojistas em um ecossistema único. Gerencie seus pets, encontre produtos de qualidade e acesse serviços especializados.',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white.withOpacity(0.9),
            height: 1.6,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 40),
        Row(
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
        const SizedBox(height: 40),
        _buildTrustIndicators(),
      ],
    );
  }

  Widget _buildAnimatedButton({
    required String text,
    required bool isPrimary,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    color: isPrimary ? AppTheme.primaryColor : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedHeroImage() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value * 0.5),
          child: Container(
            height: 400,
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
                child: const Center(
                  child: Icon(
                    Icons.pets,
                    size: 120,
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 20),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'RECURSOS PRINCIPAIS',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tudo que você precisa\npara cuidar melhor do seu pet',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ferramentas modernas e intuitivas para uma experiência completa',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
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
                          const SizedBox(height: 30),
                          _buildFeatureCard(
                              context,
                              Icons.store,
                              'Marketplace Premium',
                              'Encontre produtos e serviços verificados na sua região com entrega rápida',
                              1),
                          const SizedBox(height: 30),
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
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
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
                          size: 40,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                          height: 1.6,
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
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
                        const SizedBox(width: 20),
                        Expanded(child: _buildStatItem('15k+', 'Consultas Realizadas', Icons.medical_services)),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(child: _buildStatItem('200+', 'Cidades Atendidas', Icons.location_city)),
                        const SizedBox(width: 20),
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
    return Container(
      padding: const EdgeInsets.all(32),
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
            size: 32,
          ),
          const SizedBox(height: 16),
          Text(
            number,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveUserTypesSection(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 20),
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
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Soluções personalizadas para cada tipo de usuário',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 80),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isDesktop ? 4 : 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: isDesktop ? 1.1 : 1,
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
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
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
                    size: 32,
                    color: color,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestimonialsSection(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'O que nossos usuários dizem',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Milhares de pessoas já confiam no Pet System',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 80),
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
                        const SizedBox(height: 30),
                        _buildTestimonialCard(
                          'Dr. Carlos Mendes',
                          'Veterinário',
                          'Plataforma profissional que me conecta com mais clientes. Interface excelente!',
                          '⭐⭐⭐⭐⭐',
                        ),
                        const SizedBox(height: 30),
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
    return Container(
      padding: const EdgeInsets.all(32),
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
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          Text(
            '"$testimonial"',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.6,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            width: 60,
            height: 60,
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
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            role,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicCTASection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 20),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Junte-se a mais de 50.000 usuários que já transformaram a experiência de cuidar dos seus pets. Comece gratuitamente hoje!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
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
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
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
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Criar Conta Gratuita',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '✓ Grátis para sempre  ✓ Sem cartão de crédito  ✓ Configuração em 2 minutos',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.pets,
                      color: AppTheme.primaryColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Pet System',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'A plataforma mais completa para o universo pet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(Icons.facebook, () {}),
                  const SizedBox(width: 16),
                  _buildSocialButton(Icons.camera_alt, () {}),
                  const SizedBox(width: 16),
                  _buildSocialButton(Icons.telegram, () {}),
                  const SizedBox(width: 16),
                  _buildSocialButton(Icons.email, () {}),
                ],
              ),
              const SizedBox(height: 48),
              Container(
                height: 1,
                color: Colors.grey[800],
              ),
              const SizedBox(height: 32),
              Row(
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: Colors.grey[400],
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}