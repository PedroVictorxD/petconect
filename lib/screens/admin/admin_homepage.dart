import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../models/product.dart';
import '../../models/service.dart';
import '../../models/pet.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import 'user_management.dart';

class AdminHomepage extends StatefulWidget {
  const AdminHomepage({super.key});

  @override
  State<AdminHomepage> createState() => _AdminHomepageState();
}

class _AdminHomepageState extends State<AdminHomepage> with TickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  
  // Dados do dashboard
  List<User> _users = [];
  List<Product> _products = [];
  List<VetService> _services = [];
  List<Pet> _pets = [];
  
  bool _isLoading = true;
  
  // Estatísticas calculadas
  Map<String, int> _userStats = {};
  int _totalProducts = 0;
  int _totalServices = 0;
  int _totalPets = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadDashboardData();
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
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Painel Administrativo',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            // Header com informações do admin
            _buildAdminHeader(context, user, isMobile),
            
            // Tab bar
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    icon: Icon(Icons.dashboard, size: isMobile ? 20 : 24),
                    text: isMobile ? 'Dashboard' : 'Dashboard',
                  ),
                  Tab(
                    icon: Icon(Icons.people, size: isMobile ? 20 : 24),
                    text: isMobile ? 'Usuários' : 'Usuários',
                  ),
                  Tab(
                    icon: Icon(Icons.inventory, size: isMobile ? 20 : 24),
                    text: isMobile ? 'Produtos' : 'Produtos',
                  ),
                  Tab(
                    icon: Icon(Icons.medical_services, size: isMobile ? 20 : 24),
                    text: isMobile ? 'Serviços' : 'Serviços',
                  ),
                  Tab(
                    icon: Icon(Icons.pets, size: isMobile ? 20 : 24),
                    text: isMobile ? 'Pets' : 'Pets',
                  ),
                ],
                labelColor: AppTheme.getUserTypeColor('admin'),
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: AppTheme.getUserTypeColor('admin'),
                isScrollable: !isDesktop,
                labelStyle: TextStyle(fontSize: isMobile ? 12 : 14),
              ),
            ),
            
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDashboardTab(context, isDesktop, isMobile),
                  _buildUsersTab(context, isMobile),
                  _buildProductsTab(context, isDesktop, isMobile),
                  _buildServicesTab(context, isDesktop, isMobile),
                  _buildPetsTab(context, isDesktop, isMobile),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminHeader(BuildContext context, user, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.getUserTypeColor('admin'),
            AppTheme.getUserTypeColor('admin').withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: isMobile ? 24 : 32,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Administrador',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 18 : null,
                      ),
                    ),
                    Text(
                      user?.name ?? 'Admin',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: isMobile ? 14 : null,
                      ),
                    ),
                    Text(
                      'Painel de controle do sistema',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: isMobile ? 12 : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isMobile) ...[
            SizedBox(height: 16),
            // Status do sistema
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sistema Online',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDashboardTab(BuildContext context, bool isDesktop, bool isMobile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estatísticas gerais
          _buildGeneralStats(context, isDesktop),
          
          const SizedBox(height: 24),
          
          // Estatísticas por tipo de usuário
          _buildUserTypeStats(context, isDesktop),
          
          const SizedBox(height: 24),
          
          // Atividades recentes
          _buildRecentActivity(context),
        ],
      ),
    );
  }

  Widget _buildGeneralStats(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estatísticas Gerais',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        isDesktop
            ? Row(
                children: [
                  Expanded(child: _buildStatCard('Total de Usuários', _users.length.toString(), Icons.people, AppTheme.getUserTypeColor('admin'))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Produtos', _totalProducts.toString(), Icons.inventory, Colors.orange)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Serviços', _totalServices.toString(), Icons.medical_services, Colors.green)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Pets Cadastrados', _totalPets.toString(), Icons.pets, Colors.blue)),
                ],
              )
            : Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Usuários', _users.length.toString(), Icons.people, AppTheme.getUserTypeColor('admin'))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('Produtos', _totalProducts.toString(), Icons.inventory, Colors.orange)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Serviços', _totalServices.toString(), Icons.medical_services, Colors.green)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('Pets', _totalPets.toString(), Icons.pets, Colors.blue)),
                    ],
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildUserTypeStats(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Usuários por Tipo',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        isDesktop
            ? Row(
                children: [
                  Expanded(child: _buildUserTypeCard(Constants.adminType, 'Administradores', Icons.admin_panel_settings)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildUserTypeCard(Constants.lojistaType, 'Lojistas', Icons.store)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildUserTypeCard(Constants.tutorType, 'Tutores', Icons.pets)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildUserTypeCard(Constants.veterinarioType, 'Veterinários', Icons.medical_services)),
                ],
              )
            : Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildUserTypeCard(Constants.adminType, 'Admins', Icons.admin_panel_settings)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildUserTypeCard(Constants.lojistaType, 'Lojistas', Icons.store)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildUserTypeCard(Constants.tutorType, 'Tutores', Icons.pets)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildUserTypeCard(Constants.veterinarioType, 'Veterinários', Icons.medical_services)),
                    ],
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navegar para a aba correspondente
          if (label.contains('Usuários')) {
            _tabController.animateTo(1);
          } else if (label.contains('Produtos')) {
            _tabController.animateTo(2);
          } else if (label.contains('Serviços')) {
            _tabController.animateTo(3);
          } else if (label.contains('Pets')) {
            _tabController.animateTo(4);
          }
        },
        borderRadius: BorderRadius.circular(8),
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
      ),
    );
  }

  Widget _buildUserTypeCard(String userType, String label, IconData icon) {
    final count = _userStats[userType] ?? 0;
    final color = AppTheme.getUserTypeColor(userType.toLowerCase());
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navegar para a aba de usuários
          _tabController.animateTo(1);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                count.toString(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Atividade Recente',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navegar para página de logs completos
              },
              child: const Text('Ver tudo'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildActivityItem(
                'Novo usuário cadastrado',
                'João Silva se cadastrou como Tutor',
                Icons.person_add,
                Colors.green,
                '2 minutos atrás',
              ),
              _buildActivityItem(
                'Produto adicionado',
                'Maria Santos adicionou "Ração Premium"',
                Icons.add_box,
                Colors.blue,
                '15 minutos atrás',
              ),
              _buildActivityItem(
                'Serviço atualizado',
                'Dr. Carlos atualizou "Consulta de Rotina"',
                Icons.edit,
                Colors.orange,
                '1 hora atrás',
              ),
              _buildActivityItem(
                'Pet cadastrado',
                'Ana Costa cadastrou "Rex"',
                Icons.pets,
                Colors.purple,
                '2 horas atrás',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String description, IconData icon, Color color, String time) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(description),
      trailing: Text(
        time,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildUsersTab(BuildContext context, bool isMobile) {
    return const UserManagement();
  }

  Widget _buildProductsTab(BuildContext context, bool isDesktop, bool isMobile) {
    return Column(
      children: [
        // Header com busca (sem botão de adicionar)
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Gerenciar Produtos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 18 : null,
                      ),
                    ),
                  ),
                  // Botão de adicionar removido
                ],
              ),
              SizedBox(height: isMobile ? 12 : 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar produtos...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  // Implementar busca
                },
              ),
            ],
          ),
        ),
        
        // Lista de produtos
        Expanded(
          child: _products.isEmpty
              ? _buildEmptyState('Nenhum produto encontrado', Icons.inventory)
              : isDesktop
                  ? _buildProductsGrid()
                  : _buildProductsList(),
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showProductDialog(context, product: product);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              product.description,
              style: TextStyle(color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              product.formattedPrice,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Proprietário: ${product.ownerName ?? 'N/A'}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesTab(BuildContext context, bool isDesktop, bool isMobile) {
    return Column(
      children: [
        // Header com busca (sem botão de adicionar)
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Gerenciar Serviços',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 18 : null,
                      ),
                    ),
                  ),
                  // Botão de adicionar removido
                ],
              ),
              SizedBox(height: isMobile ? 12 : 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar serviços...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  // Implementar busca
                },
              ),
            ],
          ),
        ),
        
        // Lista de serviços
        Expanded(
          child: _services.isEmpty
              ? _buildEmptyState('Nenhum serviço encontrado', Icons.medical_services)
              : isDesktop
                  ? _buildServicesGrid()
                  : _buildServicesList(),
        ),
      ],
    );
  }

  Widget _buildServiceCard(VetService service) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    service.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showServiceDialog(context, service: service);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              service.description,
              style: TextStyle(color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              service.formattedPrice,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Veterinário: ${service.ownerName ?? 'N/A'}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetsTab(BuildContext context, bool isDesktop, bool isMobile) {
    return Column(
      children: [
        // Header com busca (sem botão de adicionar)
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Gerenciar Pets',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 18 : null,
                      ),
                    ),
                  ),
                  // Botão de adicionar removido
                ],
              ),
              SizedBox(height: isMobile ? 12 : 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar pets...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  // Implementar busca
                },
              ),
            ],
          ),
        ),
        
        // Lista de pets
        Expanded(
          child: _pets.isEmpty
              ? _buildEmptyState('Nenhum pet encontrado', Icons.pets)
              : isDesktop
                  ? _buildPetsGrid()
                  : _buildPetsList(),
        ),
      ],
    );
  }

  Widget _buildPetCard(Pet pet) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    pet.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showPetDialog(context, pet: pet);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${pet.type} - ${pet.breed}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Idade: ${pet.age} anos | Peso: ${pet.weight}kg',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              'Atividade: ${pet.activityLevel}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos para diálogos
  void _showProductDialog(BuildContext context, {Product? product}) {
    // Implementar diálogo de produto
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? 'Adicionar Produto' : 'Editar Produto'),
        content: const Text('Funcionalidade em desenvolvimento...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showServiceDialog(BuildContext context, {VetService? service}) {
    // Implementar diálogo de serviço
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service == null ? 'Adicionar Serviço' : 'Editar Serviço'),
        content: const Text('Funcionalidade em desenvolvimento...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showPetDialog(BuildContext context, {Pet? pet}) {
    // Implementar diálogo de pet
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pet == null ? 'Adicionar Pet' : 'Editar Pet'),
        content: const Text('Funcionalidade em desenvolvimento...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Carregar dados em paralelo
      await Future.wait([
        _loadUsers(authService),
        _loadProducts(authService),
        _loadServices(authService),
        _loadPets(authService),
      ]);
      
      _calculateStats();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao carregar dados do dashboard'),
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

  Future<void> _loadUsers(AuthService authService) async {
    try {
      final response = await _apiService.getUsers(token: authService.token);
      
      if (response['success'] == true) {
        final List<dynamic> usersData = response['data'] ?? [];
        setState(() {
          _users = usersData.map((data) => User.fromJson(data)).toList();
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar usuários: $e');
    }
  }

  Future<void> _loadProducts(AuthService authService) async {
    try {
      final response = await _apiService.getProducts(token: authService.token);
      
      if (response['success'] == true) {
        final List<dynamic> productsData = response['data'] ?? [];
        setState(() {
          _products = productsData.map((data) => Product.fromJson(data)).toList();
          _totalProducts = _products.length;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar produtos: $e');
      // Carregar dados demo
      _loadDemoProducts();
    }
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
      ];
      _totalProducts = _products.length;
    });
  }

  Future<void> _loadServices(AuthService authService) async {
    try {
      final response = await _apiService.getServices(token: authService.token);
      
      if (response['success'] == true) {
        final List<dynamic> servicesData = response['data'] ?? [];
        setState(() {
          _services = servicesData.map((data) => VetService.fromJson(data)).toList();
          _totalServices = _services.length;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar serviços: $e');
      // Carregar dados demo
      _loadDemoServices();
    }
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
      ];
      _totalServices = _services.length;
    });
  }

  Future<void> _loadPets(AuthService authService) async {
    try {
      final response = await _apiService.getPets(token: authService.token);
      
      if (response['success'] == true) {
        final List<dynamic> petsData = response['data'] ?? [];
        setState(() {
          _pets = petsData.map((data) => Pet.fromJson(data)).toList();
          _totalPets = _pets.length;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar pets: $e');
      // Carregar dados demo
      _loadDemoPets();
    }
  }

  void _loadDemoPets() {
    setState(() {
      _pets = [
        Pet(
          id: 1,
          name: 'Rex',
          type: 'CACHORRO',
          breed: 'Golden Retriever',
          age: 3,
          weight: 25.5,
          activityLevel: 'ALTA',
          ownerId: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Pet(
          id: 2,
          name: 'Mia',
          type: 'GATO',
          breed: 'Persa',
          age: 2,
          weight: 4.2,
          activityLevel: 'MODERADA',
          ownerId: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Pet(
          id: 3,
          name: 'Thor',
          type: 'CACHORRO',
          breed: 'Pastor Alemão',
          age: 4,
          weight: 35.0,
          activityLevel: 'MUITO_ALTA',
          ownerId: 3,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      _totalPets = _pets.length;
    });
  }

  void _calculateStats() {
    _userStats = {
      Constants.adminType: 0,
      Constants.lojistaType: 0,
      Constants.tutorType: 0,
      Constants.veterinarioType: 0,
    };

    for (final user in _users) {
      _userStats[user.userType] = (_userStats[user.userType] ?? 0) + 1;
    }
  }

  // Métodos para produtos
  Widget _buildProductsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(_products[index]);
      },
    );
  }

  Widget _buildProductsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(_products[index]);
      },
    );
  }

  // Métodos para serviços
  Widget _buildServicesGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        return _buildServiceCard(_services[index]);
      },
    );
  }

  Widget _buildServicesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        return _buildServiceCard(_services[index]);
      },
    );
  }

  // Métodos para pets
  Widget _buildPetsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _pets.length,
      itemBuilder: (context, index) {
        return _buildPetCard(_pets[index]);
      },
    );
  }

  Widget _buildPetsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pets.length,
      itemBuilder: (context, index) {
        return _buildPetCard(_pets[index]);
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}