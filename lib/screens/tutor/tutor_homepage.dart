import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/product.dart';
import '../../models/service.dart';
import '../../models/pet.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';
import '../../theme/app_theme.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
              return _buildProductCard(featuredProducts[index]);
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
        return _buildProductCard(filteredProducts[index]);
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredServices.length,
      itemBuilder: (context, index) {
        return _buildServiceCard(filteredServices[index]);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: product.imageUrl != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image, size: 40, color: Colors.grey);
                        },
                      ),
                    )
                  : const Icon(Icons.image, size: 40, color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.formattedPrice,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (product.ownerPhone != null)
                    Row(
                      children: [
                        Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            product.ownerPhone!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(VetService service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.medical_services, color: AppTheme.primaryColor),
        ),
        title: Text(
          service.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service.description),
            const SizedBox(height: 4),
            Text(
              service.formattedPrice,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (service.ownerName != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Dr. ${service.ownerName}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: service.ownerPhone != null
            ? IconButton(
                icon: const Icon(Icons.phone),
                onPressed: () {
                  // Implementar ação de contato
                  _showContactDialog(service.ownerName ?? 'Veterinário', service.ownerPhone!);
                },
              )
            : null,
      ),
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
    try {
      final response = await _apiService.getProducts(token: authService.token);
      
      if (response['success'] == true) {
        final List<dynamic> productsData = response['data'] ?? [];
        setState(() {
          _products = productsData.map((data) => Product.fromJson(data)).toList();
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar produtos: $e');
    }
  }

  Future<void> _loadServices(AuthService authService) async {
    try {
      final response = await _apiService.getServices(token: authService.token);
      
      if (response['success'] == true) {
        final List<dynamic> servicesData = response['data'] ?? [];
        setState(() {
          _services = servicesData.map((data) => VetService.fromJson(data)).toList();
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar serviços: $e');
    }
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
}