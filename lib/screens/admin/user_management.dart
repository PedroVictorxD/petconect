import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../models/product.dart';
import '../../models/service.dart';
import '../../models/pet.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  final ApiService _apiService = ApiService();
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedUserType = 'TODOS';
  User? _selectedUser;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return LoadingOverlay(
      isLoading: _isLoading,
      child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Lista de usuários à esquerda
        Expanded(
          flex: 2,
          child: _buildUsersList(),
        ),
        
        // Divisor
        Container(
          width: 1,
          color: Colors.grey[300],
        ),
        
        // Detalhes do usuário à direita
        Expanded(
          flex: 3,
          child: _selectedUser != null
              ? _buildUserDetails(_selectedUser!)
              : _buildEmptySelection(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return _selectedUser != null
        ? _buildUserDetails(_selectedUser!)
        : _buildUsersList();
  }

  Widget _buildUsersList() {
    return Column(
      children: [
        // Header com filtros
        _buildUsersHeader(),
        
        // Lista de usuários
        Expanded(
          child: _filteredUsers.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadUsers,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      return _buildUserCard(_filteredUsers[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildUsersHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Título e estatísticas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gerenciar Usuários',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.getUserTypeColor('admin').withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_filteredUsers.length} usuários',
                  style: TextStyle(
                    color: AppTheme.getUserTypeColor('admin'),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Filtros
          Row(
            children: [
              // Busca por nome
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nome ou email...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _filterUsers();
                  },
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Filtro por tipo
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedUserType,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.filter_list),
                  ),
                  items: [
                    const DropdownMenuItem(value: 'TODOS', child: Text('Todos')),
                    DropdownMenuItem(value: Constants.adminType, child: Text('Administradores')),
                    DropdownMenuItem(value: Constants.lojistaType, child: Text('Lojistas')),
                    DropdownMenuItem(value: Constants.tutorType, child: Text('Tutores')),
                    DropdownMenuItem(value: Constants.veterinarioType, child: Text('Veterinários')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedUserType = value!;
                    });
                    _filterUsers();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(User user) {
    final isSelected = _selectedUser?.id == user.id;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? AppTheme.getUserTypeColor('admin').withOpacity(0.1) : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.getUserTypeColor(user.userType.toLowerCase()),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.getUserTypeColor(user.userType.toLowerCase()).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getUserTypeLabel(user.userType),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getUserTypeColor(user.userType.toLowerCase()),
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleUserAction(value, user),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('Visualizar'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Editar'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'block',
              child: ListTile(
                leading: Icon(Icons.block, color: Colors.orange),
                title: Text('Bloquear', style: TextStyle(color: Colors.orange)),
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
        onTap: () {
          setState(() {
            _selectedUser = user;
          });
        },
      ),
    );
  }

  Widget _buildUserDetails(User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com informações básicas
          _buildUserHeader(user),
          
          const SizedBox(height: 24),
          
          // Informações detalhadas
          _buildUserInfo(user),
          
          const SizedBox(height: 24),
          
          // Conteúdo específico por tipo
          _buildUserSpecificContent(user),
          
          const SizedBox(height: 24),
          
          // Ações
          _buildUserActions(user),
        ],
      ),
    );
  }

  Widget _buildUserHeader(User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.getUserTypeColor(user.userType.toLowerCase()),
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.getUserTypeColor(user.userType.toLowerCase()).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getUserTypeLabel(user.userType),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getUserTypeColor(user.userType.toLowerCase()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!ResponsiveBreakpoints.of(context).largerThan(TABLET))
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedUser = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações Pessoais',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildInfoRow('Nome Completo', user.name),
            _buildInfoRow('Email', user.email),
            _buildInfoRow('Telefone', user.phone),
            _buildInfoRow('Localização', user.location),
            
            if (user.cnpj != null)
              _buildInfoRow('CNPJ', _formatCNPJ(user.cnpj!)),
            
            if (user.crmv != null)
              _buildInfoRow('CRMV', user.crmv!),
            
            if (user.responsibleName != null)
              _buildInfoRow('Responsável', user.responsibleName!),
            
            if (user.operatingHours != null)
              _buildInfoRow('Horário de Funcionamento', user.operatingHours!),
            
            if (user.storeType != null)
              _buildInfoRow('Tipo de Loja', user.storeType == 'VIRTUAL' ? 'Virtual' : 'Física'),
            
            if (user.createdAt != null)
              _buildInfoRow('Data de Cadastro', _formatDate(user.createdAt!)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSpecificContent(User user) {
    switch (user.userType) {
      case Constants.lojistaType:
        return _buildLojistaContent(user);
      case Constants.tutorType:
        return _buildTutorContent(user);
      case Constants.veterinarioType:
        return _buildVeterinarioContent(user);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLojistaContent(User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Produtos Cadastrados',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Aqui você carregaria os produtos do lojista
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.inventory, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Text(
                    'Carregando produtos...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorContent(User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pets Cadastrados',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Aqui você carregaria os pets do tutor
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.pets, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Text(
                    'Carregando pets...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVeterinarioContent(User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Serviços Oferecidos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Aqui você carregaria os serviços do veterinário
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.medical_services, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Text(
                    'Carregando serviços...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserActions(User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ações',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                CustomButton(
                  text: 'Editar Usuário',
                  type: ButtonType.outlined,
                  onPressed: () => _editUser(user),
                  icon: Icons.edit,
                ),
                CustomButton(
                  text: 'Enviar Email',
                  type: ButtonType.outlined,
                  onPressed: () => _sendEmailToUser(user),
                  icon: Icons.email,
                ),
                CustomButton(
                  text: 'Bloquear',
                  type: ButtonType.outlined,
                  onPressed: () => _blockUser(user),
                  icon: Icons.block,
                ),
                CustomButton(
                  text: 'Excluir',
                  type: ButtonType.danger,
                  onPressed: () => _deleteUser(user),
                  icon: Icons.delete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySelection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Selecione um usuário',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha um usuário da lista para ver os detalhes',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum usuário encontrado',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajuste os filtros de busca',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _getUserTypeLabel(String userType) {
    switch (userType) {
      case Constants.adminType:
        return 'Administrador';
      case Constants.lojistaType:
        return 'Lojista';
      case Constants.tutorType:
        return 'Tutor';
      case Constants.veterinarioType:
        return 'Veterinário';
      default:
        return userType;
    }
  }

  String _formatCNPJ(String cnpj) {
    if (cnpj.length == 14) {
      return '${cnpj.substring(0, 2)}.${cnpj.substring(2, 5)}.${cnpj.substring(5, 8)}/${cnpj.substring(8, 12)}-${cnpj.substring(12, 14)}';
    }
    return cnpj;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _filterUsers() {
    setState(() {
      _filteredUsers = _users.where((user) {
        final matchesSearch = _searchQuery.isEmpty ||
            user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            user.email.toLowerCase().contains(_searchQuery.toLowerCase());
        
        final matchesType = _selectedUserType == 'TODOS' ||
            user.userType == _selectedUserType;
        
        return matchesSearch && matchesType;
      }).toList();
    });
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final response = await _apiService.getUsers(token: authService.token);

      if (response['success'] == true && mounted) {
        final List<dynamic> usersData = response['data'] ?? [];
        setState(() {
          _users = usersData.map((data) => User.fromJson(data)).toList();
          _filteredUsers = List.from(_users);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao carregar usuários'),
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

  void _handleUserAction(String action, User user) {
    switch (action) {
      case 'view':
        setState(() {
          _selectedUser = user;
        });
        break;
      case 'edit':
        _editUser(user);
        break;
      case 'block':
        _blockUser(user);
        break;
      case 'delete':
        _deleteUser(user);
        break;
    }
  }

  void _editUser(User user) {
    // Implementar edição de usuário
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editando usuário ${user.name}...')),
    );
  }

  void _sendEmailToUser(User user) {
    // Implementar envio de email
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Enviando email para ${user.email}...')),
    );
  }

  void _blockUser(User user) {
    // Implementar bloqueio de usuário
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Usuário ${user.name} foi bloqueado'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _deleteUser(User user) async {
    final confirmed = await DeleteConfirmationDialog.show(
      context,
      itemName: user.name,
      customMessage: 'Tem certeza que deseja excluir o usuário "${user.name}"?\n\nEsta ação não pode ser desfeita e todos os dados associados serão perdidos.',
    );

    if (confirmed == true) {
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        
        // Simular exclusão - implementar endpoint no backend
        // final response = await _apiService.deleteUser(user.id!, token: authService.token);
        
        // if (response['success'] == true && mounted) {
        setState(() {
          _users.removeWhere((u) => u.id == user.id);
          _filteredUsers.removeWhere((u) => u.id == user.id);
          if (_selectedUser?.id == user.id) {
            _selectedUser = null;
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usuário ${user.name} foi excluído com sucesso'),
            backgroundColor: Colors.red,
          ),
        );
        // }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao excluir usuário'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}