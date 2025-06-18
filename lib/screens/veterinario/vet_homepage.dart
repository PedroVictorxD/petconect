import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../theme/app_theme.dart';
import 'service_form_dialog.dart';

class VetHomepage extends StatefulWidget {
  const VetHomepage({super.key});

  @override
  State<VetHomepage> createState() => _VetHomepageState();
}

class _VetHomepageState extends State<VetHomepage> {
  final ApiService _apiService = ApiService();
  List<VetService> _services = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Meus Serviços',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadServices,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            // Header com estatísticas e busca
            _buildHeader(context, user, isDesktop, isMobile),
            
            // Lista de serviços
            Expanded(
              child: _buildServicesList(context, isDesktop, isMobile),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showServiceDialog(context),
        icon: const Icon(Icons.add),
        label: Text(isMobile ? 'Novo' : 'Novo Serviço'),
        backgroundColor: AppTheme.getUserTypeColor('veterinario'),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, user, bool isDesktop, bool isMobile) {
    final filteredServices = _getFilteredServices();
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.getUserTypeColor('veterinario'),
            AppTheme.getUserTypeColor('veterinario').withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          // Boas-vindas e informações do veterinário
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.medical_services,
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
                      'Dr. ${user?.name ?? 'Veterinário'}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 16 : null,
                      ),
                    ),
                    if (user?.crmv != null)
                      Text(
                        'CRMV: ${user!.crmv}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: isMobile ? 12 : null,
                        ),
                      ),
                    Text(
                      '${_services.length} serviços cadastrados',
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
          
          SizedBox(height: isMobile ? 16 : 20),
          
          // Estatísticas
          if (isDesktop)
            Row(
              children: [
                Expanded(child: _buildStatCard('Total de Serviços', _services.length.toString(), Icons.medical_services)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Serviços Ativos', _services.length.toString(), Icons.check_circle)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Valor Médio', _calculateAveragePrice(), Icons.attach_money)),
              ],
            )
          else if (isMobile)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildStatCard('Total', _services.length.toString(), Icons.medical_services)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatCard('Valor Médio', _calculateAveragePrice(), Icons.attach_money)),
                  ],
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: _buildStatCard('Total', _services.length.toString(), Icons.medical_services)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Valor Médio', _calculateAveragePrice(), Icons.attach_money)),
              ],
            ),
          
          SizedBox(height: isMobile ? 16 : 20),
          
          // Barra de busca
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Buscar serviços...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.7)),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white, width: 2),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList(BuildContext context, bool isDesktop, bool isMobile) {
    final filteredServices = _getFilteredServices();

    if (filteredServices.isEmpty && !_isLoading) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: _loadServices,
      child: isDesktop
          ? _buildDesktopGrid(filteredServices)
          : isMobile
              ? _buildMobileList(filteredServices)
              : _buildMobileList(filteredServices),
    );
  }

  Widget _buildDesktopGrid(List<VetService> services) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return _buildServiceCard(services[index], isGrid: true);
      },
    );
  }

  Widget _buildMobileList(List<VetService> services) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return _buildServiceCard(services[index], isGrid: false);
      },
    );
  }

  Widget _buildServiceCard(VetService service, {required bool isGrid}) {
    return Card(
      elevation: 2,
      child: isGrid
          ? _buildGridServiceCard(service)
          : _buildListServiceCard(service),
    );
  }

  Widget _buildGridServiceCard(VetService service) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone do serviço
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.getUserTypeColor('veterinario').withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.medical_services,
                  color: AppTheme.getUserTypeColor('veterinario'),
                  size: 24,
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _showServiceDialog(context, service: service);
                      break;
                    case 'delete':
                      _confirmDelete(service);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Editar'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Excluir', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Nome do serviço
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    service.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  service.formattedPrice,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.getUserTypeColor('veterinario'),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListServiceCard(VetService service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.getUserTypeColor('veterinario').withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.medical_services,
            color: AppTheme.getUserTypeColor('veterinario'),
          ),
        ),
        title: Text(
          service.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              service.formattedPrice,
              style: TextStyle(
                color: AppTheme.getUserTypeColor('veterinario'),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showServiceDialog(context, service: service);
                break;
              case 'delete':
                _confirmDelete(service);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Editar'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Excluir', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 120,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isNotEmpty
                ? 'Nenhum serviço encontrado'
                : 'Nenhum serviço cadastrado',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'Tente buscar por outro termo'
                : 'Cadastre seu primeiro serviço para começar a atender',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (_searchQuery.isEmpty)
            CustomButton(
              text: 'Cadastrar Primeiro Serviço',
              onPressed: () => _showServiceDialog(context),
              icon: Icons.add,
            ),
        ],
      ),
    );
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

  String _calculateAveragePrice() {
    if (_services.isEmpty) return 'R\$ 0,00';
    
    double total = _services.fold(0, (sum, service) => sum + service.price);
    double average = total / _services.length;
    
    return 'R\$ ${average.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      
      if (user != null) {
        final response = await _apiService.getServices(
          token: authService.token,
          ownerId: user.id,
        );

        if (response['success'] == true && mounted) {
          final List<dynamic> servicesData = response['data'] ?? [];
          setState(() {
            _services = servicesData.map((data) => VetService.fromJson(data)).toList();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao carregar serviços'),
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

  void _showServiceDialog(BuildContext context, {VetService? service}) {
    showDialog(
      context: context,
      builder: (context) => ServiceFormDialog(
        service: service,
        onSaved: (savedService) {
          _loadServices(); // Recarregar lista após salvar
        },
      ),
    );
  }

  Future<void> _confirmDelete(VetService service) async {
    final confirmed = await DeleteConfirmationDialog.show(
      context,
      itemName: service.name,
    );

    if (confirmed == true) {
      await _deleteService(service);
    }
  }

  Future<void> _deleteService(VetService service) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final response = await _apiService.deleteService(
        service.id!,
        token: authService.token,
      );

      if (response['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Serviço excluído com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
        _loadServices(); // Recarregar lista
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao excluir serviço'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao excluir serviço'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}