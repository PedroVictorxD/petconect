import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../widgets/custom_button.dart';
import '../../theme/app_theme.dart';
import '../../utils/routes.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header com barra de navegação
          SliverAppBar(
            pinned: true,
            expandedHeight: 0,
            backgroundColor: AppTheme.primaryColor,
            title: Row(
              children: [
                Icon(Icons.pets, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Text(
                  'Pet System',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CustomButton(
                  text: 'Acessar Sistema',
                  type: ButtonType.secondary,
                  onPressed: () => context.go(Routes.login),
                ),
              ),
            ],
          ),
          
          // Conteúdo principal
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Hero Section
                _buildHeroSection(context, isDesktop),
                
                // Features Section
                _buildFeaturesSection(context, isDesktop),
                
                // User Types Section
                _buildUserTypesSection(context, isDesktop),
                
                // CTA Section
                _buildCTASection(context),
                
                // Footer
                _buildFooter(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isDesktop 
              ? Row(
                  children: [
                    Expanded(child: _buildHeroContent(context)),
                    const SizedBox(width: 60),
                    Expanded(child: _buildHeroImage()),
                  ],
                )
              : Column(
                  children: [
                    _buildHeroContent(context),
                    const SizedBox(height: 40),
                    _buildHeroImage(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeroContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conectando o mundo Pet',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 48,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'A plataforma completa que conecta tutores, veterinários e lojistas em um só lugar. Gerencie seus pets, encontre produtos e serviços de qualidade.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white.withOpacity(0.9),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            CustomButton(
              text: 'Começar Agora',
              type: ButtonType.secondary,
              onPressed: () => context.go(Routes.register),
              width: 180,
              height: 56,
            ),
            const SizedBox(width: 16),
            CustomButton(
              text: 'Fazer Login',
              type: ButtonType.outlined,
              onPressed: () => context.go(Routes.login),
              width: 150,
              height: 56,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.1),
      ),
      child: const Center(
        child: Icon(
          Icons.pets,
          size: 120,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'Recursos do Sistema',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Tudo que você precisa para cuidar melhor do seu pet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              isDesktop
                  ? Row(
                      children: [
                        Expanded(child: _buildFeatureCard(context, Icons.calculate, 'Calculadora de Ração', 'Calcule a quantidade ideal de ração baseada no peso e atividade do seu pet')),
                        const SizedBox(width: 30),
                        Expanded(child: _buildFeatureCard(context, Icons.store, 'Marketplace', 'Encontre produtos e serviços para pets na sua região')),
                        const SizedBox(width: 30),
                        Expanded(child: _buildFeatureCard(context, Icons.medical_services, 'Gestão Veterinária', 'Conecte-se com veterinários e gerencie consultas')),
                      ],
                    )
                  : Column(
                      children: [
                        _buildFeatureCard(context, Icons.calculate, 'Calculadora de Ração', 'Calcule a quantidade ideal de ração baseada no peso e atividade do seu pet'),
                        const SizedBox(height: 30),
                        _buildFeatureCard(context, Icons.store, 'Marketplace', 'Encontre produtos e serviços para pets na sua região'),
                        const SizedBox(height: 30),
                        _buildFeatureCard(context, Icons.medical_services, 'Gestão Veterinária', 'Conecte-se com veterinários e gerencie consultas'),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String title, String description) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
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
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypesSection(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      color: Colors.grey[50],
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'Para Todos os Tipos de Usuário',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isDesktop ? 4 : 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: isDesktop ? 1.2 : 1,
                children: [
                  _buildUserTypeCard(context, Icons.pets, 'Tutores', 'Gerencie seus pets e encontre produtos', AppTheme.getUserTypeColor('tutor')),
                  _buildUserTypeCard(context, Icons.store, 'Lojistas', 'Cadastre produtos e alcance clientes', AppTheme.getUserTypeColor('lojista')),
                  _buildUserTypeCard(context, Icons.medical_services, 'Veterinários', 'Ofereça serviços especializados', AppTheme.getUserTypeColor('veterinario')),
                  _buildUserTypeCard(context, Icons.admin_panel_settings, 'Administradores', 'Gerencie toda a plataforma', AppTheme.getUserTypeColor('admin')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeCard(BuildContext context, IconData icon, String title, String description, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTASection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.secondaryColor,
            AppTheme.secondaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Text(
                'Pronto para começar?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Junte-se à maior plataforma de cuidados para pets do Brasil.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Criar Conta Gratuita',
                type: ButtonType.primary,
                onPressed: () => context.go(Routes.register),
                width: 250,
                height: 56,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      color: Colors.grey[900],
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, color: AppTheme.primaryColor, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    'Pet System',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                '© 2024 Pet System. Todos os direitos reservados.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}