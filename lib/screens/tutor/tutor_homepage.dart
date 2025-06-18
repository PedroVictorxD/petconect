import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/product.dart';
import '../../models/service.dart';
import '../../models/pet.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';
import 'pet_management.dart';
import 'food_calculator.dart';

class TutorHomepage extends StatefulWidget {
  const TutorHomepage({super.key});

  @override
  State<TutorHomepage> createState() => _TutorHomepageState();
}

class _TutorHomepageState extends State<TutorHomepage> with TickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  
  List<Product> _products = [];
  List<VetService> _services = [];
  List<Pet> _pets = [];
  bool _isLoading = true;
  String _searchQuery = '';

  // Animações
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Inicializar animações
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Dashboard do Tutor',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Welcome header
          _buildWelcomeHeader(context, user),
          
          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
                Tab(icon: Icon(Icons.pets), text: 'Meus Pets'),
                Tab(icon: Icon(Icons.store), text: 'Produtos'),
                Tab(icon: Icon(Icons.medical_services), text: 'Serviços'),
              ],
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: AppTheme.primaryColor,
            ),
          ),
          
          // Tab content
          Expanded(
            child: LoadingOverlay(
              isLoading: _isLoading,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDashboardTab(context, isDesktop),
                  _buildPetsTab(context),
                  _buildProductsTab(context, isDesktop),
                  _buildServicesTab(context, isDesktop),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(
              Icons.pets,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, ${user?.name ?? 'Tutor'}!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Gerencie seus pets e encontre produtos e serviços',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(BuildContext context, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estatísticas rápidas
          _buildStatsCards(context, isDesktop),
          
          const SizedBox(height: 24),
          
          // Ações rápidas
          _buildQuickActions(context, isDesktop),
          
          const SizedBox(height: 24),
          
          // Produtos em destaque
          _buildFeaturedProducts(context),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumo',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        isDesktop
            ? Row(
                children: [
                  Expanded(child: _buildStatCard('Meus Pets', _pets.length.toString(), Icons.pets, Colors.blue)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Produtos', _products.length.toString(), Icons.store, Colors.orange)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Serviços', _services.length.toString(), Icons.medical_services, Colors.green)),
                ],
              )
            : Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Meus Pets', _pets.length.toString(), Icons.pets, Colors.blue)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('Produtos', _products.length.toString(), Icons.store, Colors.orange)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard('Serviços Disponíveis', _services.length.toString(), Icons.medical_services, Colors.green),
                ],
              ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
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

  Widget _buildQuickActions(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        isDesktop
            ? Row(
                children: [
                  Expanded(child: _buildActionCard('Gerenciar Pets', 'Adicione e gerencie seus pets', Icons.pets, () => _openPetManagement())),
                  const SizedBox(width: 16),
                  Expanded(child: _buildActionCard('Calculadora de Ração', 'Calcule a quantidade ideal', Icons.calculate, () => _openFoodCalculator())),
                ],
              )
            : Column(
                children: [
                  _buildActionCard('Gerenciar Pets', 'Adicione e gerencie seus pets', Icons.pets, () => _openPetManagement()),
                  const SizedBox(height: 12),
                  _buildActionCard('Calculadora de Ração', 'Calcule a quantidade ideal', Icons.calculate, () => _openFoodCalculator()),
                ],
              ),
      ],
    );
  }

  Widget _buildActionCard(String title, String description, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 24),
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
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedProducts(BuildContext context) {
    final featuredProducts = _products.take(3).toList();
    
    if (featuredProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Produtos em Destaque',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => _tabController.animateTo(2),
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: featuredProducts.length,
            itemBuilder: (context, index) {
              return _buildProductCard(featuredProducts[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPetsTab(BuildContext context) {
    return const PetManagement();
  }

  Widget _buildProductsTab(BuildContext context, bool isDesktop) {
    return Column(
      children: [
        // Barra de busca
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar produtos...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        
        // Lista de produtos
        Expanded(
          child: _buildProductsList(context, isDesktop),
        ),
      ],
    );
  }

  Widget _buildServicesTab(BuildContext context, bool isDesktop) {
    return Column(
      children: [
        // Barra de busca
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar serviços...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        
        // Lista de serviços
        Expanded(
          child: _buildServicesList(context, isDesktop),
        ),
      ],
    );
  }

  Widget _buildProductsList(BuildContext context, bool isDesktop) {
    final filteredProducts = _getFilteredProducts();

    if (filteredProducts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nenhum produto encontrado'),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        return _buildProductCard(filteredProducts[index], index);
      },
    );
  }

  Widget _buildServicesList(BuildContext context, bool isDesktop) {
    final filteredServices = _getFilteredServices();

    if (filteredServices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nenhum serviço encontrado'),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 2 : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isDesktop ? 1.1 : 1.2,
      ),
      itemCount: filteredServices.length,
      itemBuilder: (context, index) {
        return _buildServiceCard(filteredServices[index], index);
      },
    );
  }

  Widget _buildProductCard(Product product, int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final animation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            (index + 1) * 0.1,
            curve: Curves.easeInOut,
          ),
        ));

        return Transform.translate(
          offset: Offset(0, 50 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value,
            child: Container(
              width: ResponsiveBreakpoints.of(context).isMobile ? double.infinity : 280,
              height: 200,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showProductDetails(product),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Imagem do produto
                        Expanded(
                          flex: 3,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: NetworkImage(product.imageUrl ?? 'https://images.unsplash.com/photo-1601758228041-3caa5d9c6c5f?w=400&h=300&fit=crop'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Nome do produto
                        Expanded(
                          flex: 2,
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Preço e ações
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                product.formattedPrice,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Row(
                                children: [
                                  // Botão WhatsApp
                                  GestureDetector(
                                    onTap: () => _openWhatsApp(product.ownerPhone ?? '', product.name),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.chat,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  // Botão telefone
                                  GestureDetector(
                                    onTap: () => _makePhoneCall(product.ownerPhone ?? ''),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.phone,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildServiceCard(VetService service, int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final animation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            (index + 1) * 0.1,
            curve: Curves.easeInOut,
          ),
        ));

        return Transform.translate(
          offset: Offset(0, 50 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value,
            child: Container(
              height: 280,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    AppTheme.primaryColor.withOpacity(0.05),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _showServiceDetails(service),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ícone do serviço
                        Expanded(
                          flex: 4,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.primaryColor.withOpacity(0.1),
                                  AppTheme.primaryColor.withOpacity(0.2),
                                ],
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.medical_services,
                                  size: 60,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Serviço Veterinário',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.primaryColor.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Nome do serviço
                        Expanded(
                          flex: 2,
                          child: Text(
                            service.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Descrição do serviço
                        Expanded(
                          flex: 2,
                          child: Text(
                            service.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Preço e ações
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Preço',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    service.formattedPrice,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  // Botão WhatsApp
                                  GestureDetector(
                                    onTap: () => _openWhatsApp(service.ownerPhone ?? '', service.name),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.green.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.chat,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Botão telefone
                                  GestureDetector(
                                    onTap: () => _makePhoneCall(service.ownerPhone ?? ''),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primaryColor.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.phone,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Product> _getFilteredProducts() {
    if (_searchQuery.isEmpty) {
      return _products;
    }
    
    return _products.where((product) {
      return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             product.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<VetService> _getFilteredServices() {
    if (_searchQuery.isEmpty) {
      return _services;
    }
    
    return _services.where((service) {
      return service.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             service.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Carregar produtos, serviços e pets em paralelo
      await Future.wait([
        _loadProducts(authService),
        _loadServices(authService),
        _loadPets(authService),
      ]);
      
      // Iniciar animações após carregar os dados
      if (mounted) {
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao carregar dados'),
            backgroundColor: Colors.red,
          ),
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

  Future<void> _loadProducts(AuthService authService) async {
    // Carregar dados demo para demonstração
    _loadDemoProducts();
  }

  void _loadDemoProducts() {
    setState(() {
      _products = [
        Product(
          id: 1,
          name: 'Ração Premium para Cães',
          description: 'Ração de alta qualidade para cães adultos, rica em proteínas e vitaminas essenciais.',
          price: 89.90,
          imageUrl: 'https://images.unsplash.com/photo-1601758228041-3caa5d9c6c5f?w=400&h=300&fit=crop',
          measurementUnit: 'KG',
          ownerName: 'Pet Shop Central',
          ownerPhone: '(11) 99999-8888',
          ownerId: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 2,
          name: 'Brinquedo Interativo para Gatos',
          description: 'Brinquedo que estimula a caça e exercício dos gatos, com bolinhas e penas.',
          price: 45.50,
          imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=300&fit=crop',
          measurementUnit: 'UNIDADE',
          ownerName: 'Pet Shop Feliz',
          ownerPhone: '(11) 88888-7777',
          ownerId: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 3,
          name: 'Coleira Ajustável com Identificação',
          description: 'Coleira confortável e segura com placa de identificação personalizada.',
          price: 35.00,
          imageUrl: 'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=400&h=300&fit=crop',
          measurementUnit: 'UNIDADE',
          ownerName: 'Pet Shop Central',
          ownerPhone: '(11) 99999-8888',
          ownerId: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 4,
          name: 'Shampoo Hipoalergênico para Cães',
          description: 'Shampoo especial para cães com pele sensível, sem fragrâncias fortes.',
          price: 28.90,
          imageUrl: 'https://images.unsplash.com/photo-1601758228041-3caa5d9c6c5f?w=400&h=300&fit=crop',
          measurementUnit: 'ML',
          ownerName: 'Pet Shop Feliz',
          ownerPhone: '(11) 88888-7777',
          ownerId: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 5,
          name: 'Cama para Cães Portátil',
          description: 'Cama confortável e dobrável, ideal para viagens e passeios.',
          price: 120.00,
          imageUrl: 'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=400&h=300&fit=crop',
          measurementUnit: 'UNIDADE',
          ownerName: 'Pet Shop Central',
          ownerPhone: '(11) 99999-8888',
          ownerId: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 6,
          name: 'Snacks Naturais para Gatos',
          description: 'Snacks 100% naturais, sem conservantes artificiais.',
          price: 22.50,
          imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=300&fit=crop',
          measurementUnit: 'G',
          ownerName: 'Pet Shop Feliz',
          ownerPhone: '(11) 88888-7777',
          ownerId: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
    });
  }

  Future<void> _loadServices(AuthService authService) async {
    // Carregar dados demo para demonstração
    _loadDemoServices();
  }

  void _loadDemoServices() {
    setState(() {
      _services = [
        VetService(
          id: 1,
          name: 'Consulta Veterinária Geral',
          description: 'Consulta completa com exame físico, orientações sobre alimentação e cuidados preventivos.',
          price: 120.00,
          ownerName: 'Dr. Maria Santos',
          ownerPhone: '(11) 99999-1111',
          ownerId: 1,
          ownerCrmv: 'CRMV-SP 12345',
          operatingHours: 'Seg-Sex: 8h-18h',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        VetService(
          id: 2,
          name: 'Vacinação Completa',
          description: 'Aplicação de todas as vacinas necessárias para cães e gatos.',
          price: 85.00,
          ownerName: 'Dr. Carlos Mendes',
          ownerPhone: '(11) 88888-2222',
          ownerId: 2,
          ownerCrmv: 'CRMV-SP 67890',
          operatingHours: 'Seg-Sex: 9h-17h',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        VetService(
          id: 3,
          name: 'Banho e Tosa',
          description: 'Banho completo com produtos hipoalergênicos e tosa profissional.',
          price: 65.00,
          ownerName: 'Dr. Ana Silva',
          ownerPhone: '(11) 77777-3333',
          ownerId: 3,
          ownerCrmv: 'CRMV-SP 11111',
          operatingHours: 'Seg-Sáb: 8h-19h',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        VetService(
          id: 4,
          name: 'Exame de Sangue',
          description: 'Exames laboratoriais completos para check-up geral.',
          price: 150.00,
          ownerName: 'Dr. Maria Santos',
          ownerPhone: '(11) 99999-1111',
          ownerId: 1,
          ownerCrmv: 'CRMV-SP 12345',
          operatingHours: 'Seg-Sex: 8h-18h',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        VetService(
          id: 5,
          name: 'Castração',
          description: 'Procedimento cirúrgico seguro com acompanhamento pós-operatório.',
          price: 300.00,
          ownerName: 'Dr. Carlos Mendes',
          ownerPhone: '(11) 88888-2222',
          ownerId: 2,
          ownerCrmv: 'CRMV-SP 67890',
          operatingHours: 'Seg-Sex: 9h-17h',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        VetService(
          id: 6,
          name: 'Fisioterapia para Cães',
          description: 'Sessões de fisioterapia para reabilitação e bem-estar.',
          price: 95.00,
          ownerName: 'Dr. Ana Silva',
          ownerPhone: '(11) 77777-3333',
          ownerId: 3,
          ownerCrmv: 'CRMV-SP 11111',
          operatingHours: 'Seg-Sáb: 8h-19h',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
    });
  }

  Future<void> _loadPets(AuthService authService) async {
    try {
      final user = authService.currentUser;
      if (user != null) {
        final response = await _apiService.getPets(
          token: authService.token,
          ownerId: user.id,
        );
        
        if (response['success'] == true) {
          final List<dynamic> petsData = response['data'] ?? [];
          setState(() {
            _pets = petsData.map((data) => Pet.fromJson(data)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar pets: $e');
    }
  }

  void _openPetManagement() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PetManagement(),
      ),
    );
  }

  void _openFoodCalculator() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FoodCalculator(),
      ),
    );
  }

  void _showContactDialog(String name, String phone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contatar $name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Telefone: $phone'),
            const SizedBox(height: 16),
            const Text('Como você gostaria de entrar em contato?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          CustomButton(
            text: 'Ligar',
            onPressed: () {
              // Implementar ação de ligação
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ligando para $phone...')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showProductDetails(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.imageUrl != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(product.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              product.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              'Preço: ${product.formattedPrice}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            if (product.ownerPhone != null) ...[
              const SizedBox(height: 12),
              Text(
                'Contato: ${product.ownerPhone}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          if (product.ownerPhone != null)
            CustomButton(
              text: 'Contatar',
              onPressed: () {
                Navigator.of(context).pop();
                _showContactDialog('Vendedor', product.ownerPhone!);
              },
            ),
        ],
      ),
    );
  }

  void _showServiceDetails(VetService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.medical_services,
                color: AppTheme.primaryColor,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              service.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              'Preço: ${service.formattedPrice}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            if (service.ownerName != null) ...[
              const SizedBox(height: 12),
              Text(
                'Veterinário: Dr. ${service.ownerName}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
            if (service.ownerPhone != null) ...[
              const SizedBox(height: 8),
              Text(
                'Contato: ${service.ownerPhone}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          if (service.ownerPhone != null)
            CustomButton(
              text: 'Agendar',
              onPressed: () {
                Navigator.of(context).pop();
                _showContactDialog(service.ownerName ?? 'Veterinário', service.ownerPhone!);
              },
            ),
        ],
      ),
    );
  }

  void _openWhatsApp(String phone, String productName) {
    // Remove caracteres especiais do telefone
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final message = 'Olá! Gostaria de saber mais sobre o produto/serviço: $productName';
    
    // URL do WhatsApp Web
    final whatsappUrl = 'https://wa.me/55$cleanPhone?text=${Uri.encodeComponent(message)}';
    
    // Mostra snackbar informativo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abrindo WhatsApp para $productName'),
        action: SnackBarAction(
          label: 'Copiar Link',
          onPressed: () {
            // Aqui você pode implementar a cópia do link para a área de transferência
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Link copiado!')),
            );
          },
        ),
      ),
    );
  }

  void _makePhoneCall(String phone) {
    // Remove caracteres especiais do telefone
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Mostra snackbar informativo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ligando para $phone'),
        action: SnackBarAction(
          label: 'Copiar Número',
          onPressed: () {
            // Aqui você pode implementar a cópia do número para a área de transferência
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Número copiado!')),
            );
          },
        ),
      ),
    );
  }
}