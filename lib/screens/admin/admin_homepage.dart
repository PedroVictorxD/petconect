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
    _tabController = TabController(length: 4, vsync: this);
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
            _buildAdminHeader(context, user),
            
            // Tab bar
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
                  Tab(icon: Icon(Icons.people), text: 'Usuários'),
                  Tab(icon: Icon(Icons.analytics), text: 'Relatórios'),
                  Tab(icon: Icon(Icons.settings), text: 'Sistema'),
                ],
                labelColor: AppTheme.getUserTypeColor('admin'),
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: AppTheme.getUserTypeColor('admin'),
                isScrollable: !isDesktop,
              ),
            ),
            
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDashboardTab(context, isDesktop),
                  _buildUsersTab(context),
                  _buildReportsTab(context, isDesktop),
                  _buildSystemTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminHeader(BuildContext context, user) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Administrador',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.name ?? 'Admin',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  'Painel de controle do sistema',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
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
      ),
    );
  }

  Widget _buildDashboardTab(BuildContext context, bool isDesktop) {
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

  Widget _buildUserTypeCard(String userType, String label, IconData icon) {
    final count = _userStats[userType] ?? 0;
    final color = AppTheme.getUserTypeColor(userType.toLowerCase());
    
    return Card(
      elevation: 2,
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

  Widget _buildUsersTab(BuildContext context) {
    return const UserManagement();
  }

  Widget _buildReportsTab(BuildContext context, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Relatórios do Sistema',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Cards de relatórios
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isDesktop ? 3 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildReportCard(
                'Relatório de Usuários',
                'Estatísticas detalhadas dos usuários',
                Icons.people,
                Colors.blue,
                () => _generateUserReport(),
              ),
              _buildReportCard(
                'Relatório de Produtos',
                'Produtos mais vendidos e estatísticas',
                Icons.inventory,
                Colors.orange,
                () => _generateProductReport(),
              ),
              _buildReportCard(
                'Relatório de Serviços',
                'Serviços mais procurados',
                Icons.medical_services,
                Colors.green,
                () => _generateServiceReport(),
              ),
              _buildReportCard(
                'Relatório Financeiro',
                'Movimentação financeira da plataforma',
                Icons.attach_money,
                Colors.purple,
                () => _generateFinancialReport(),
              ),
              _buildReportCard(
                'Relatório de Atividade',
                'Logs de atividade do sistema',
                Icons.timeline,
                Colors.red,
                () => _generateActivityReport(),
              ),
              _buildReportCard(
                'Relatório Personalizado',
                'Crie relatórios customizados',
                Icons.build,
                Colors.teal,
                () => _showCustomReportDialog(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
      ),
    );
  }

  Widget _buildSystemTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configurações do Sistema',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Configurações gerais
          _buildSystemCard(
            'Configurações Gerais',
            'Configurações básicas do sistema',
            Icons.settings,
            [
              _buildSystemOption('Manutenção do Sistema', 'Ativar modo de manutenção', false),
              _buildSystemOption('Novos Cadastros', 'Permitir novos cadastros', true),
              _buildSystemOption('Notificações', 'Enviar notificações por email', true),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Backup e segurança
          _buildSystemCard(
            'Backup e Segurança',
            'Gerenciamento de backups e segurança',
            Icons.security,
            [
              ListTile(
                title: const Text('Fazer Backup'),
                subtitle: const Text('Último backup: Hoje, 03:00'),
                trailing: CustomButton(
                  text: 'Executar',
                  type: ButtonType.outlined,
                  onPressed: _performBackup,
                ),
              ),
              ListTile(
                title: const Text('Logs de Segurança'),
                subtitle: const Text('Visualizar logs de acesso'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _viewSecurityLogs,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Informações do sistema
          _buildSystemCard(
            'Informações do Sistema',
            'Detalhes técnicos da aplicação',
            Icons.info,
            [
              _buildInfoItem('Versão', '1.0.0'),
              _buildInfoItem('Build', '2024.06.001'),
              _buildInfoItem('Ambiente', 'Produção'),
              _buildInfoItem('Uptime', '15 dias, 4 horas'),
              _buildInfoItem('Último Deploy', '15/06/2024 14:30'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemCard(String title, String subtitle, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.getUserTypeColor('admin')),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSystemOption(String title, String subtitle, bool value) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: (newValue) {
        // Implementar alteração de configuração
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title ${newValue ? 'ativado' : 'desativado'}')),
        );
      },
      activeColor: AppTheme.getUserTypeColor('admin'),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.grey[600]),
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
    }
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
    }
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
    }
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

  void _generateUserReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gerando relatório de usuários...'),
        backgroundColor: Colors.blue,
      ),
    );
    // Implementar geração de relatório
  }

  void _generateProductReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gerando relatório de produtos...'),
        backgroundColor: Colors.orange,
      ),
    );
    // Implementar geração de relatório
  }

  void _generateServiceReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gerando relatório de serviços...'),
        backgroundColor: Colors.green,
      ),
    );
    // Implementar geração de relatório
  }

  void _generateFinancialReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gerando relatório financeiro...'),
        backgroundColor: Colors.purple,
      ),
    );
    // Implementar geração de relatório
  }

  void _generateActivityReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gerando relatório de atividade...'),
        backgroundColor: Colors.red,
      ),
    );
    // Implementar geração de relatório
  }

  void _showCustomReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Relatório Personalizado'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Funcionalidade em desenvolvimento.'),
            SizedBox(height: 16),
            Text('Em breve você poderá criar relatórios personalizados com filtros avançados.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _performBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Iniciando backup do sistema...'),
        backgroundColor: Colors.blue,
      ),
    );
    // Implementar backup
  }

  void _viewSecurityLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Abrindo logs de segurança...'),
        backgroundColor: Colors.orange,
      ),
    );
    // Implementar visualização de logs
  }
}