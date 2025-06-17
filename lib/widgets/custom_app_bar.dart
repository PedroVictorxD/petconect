import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showLogout;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.showLogout = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return AppBar(
      title: Text(title),
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      actions: [
        // Informações do usuário
        if (user != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.getUserTypeColor(user.userType),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _getUserTypeLabel(user.userType),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        
        // Ações customizadas
        if (actions != null) ...actions!,
        
        // Menu do usuário
        if (user != null)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Perfil'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Configurações'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              if (showLogout)
                const PopupMenuItem(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text('Sair', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  void _handleMenuAction(BuildContext context, String action) async {
    final authService = Provider.of<AuthService>(context, listen: false);

    switch (action) {
      case 'profile':
        _showProfileDialog(context);
        break;
      case 'settings':
        _showSettingsDialog(context);
        break;
      case 'logout':
        final confirmed = await _showLogoutConfirmation(context);
        if (confirmed) {
          await authService.logout();
          if (context.mounted) {
            context.go('/');
          }
        }
        break;
    }
  }

  void _showProfileDialog(BuildContext context) {
    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informações do Perfil'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileItem('Nome', user.name),
              _buildProfileItem('Email', user.email),
              _buildProfileItem('Tipo', _getUserTypeLabel(user.userType)),
              _buildProfileItem('Localização', user.location),
              _buildProfileItem('Telefone', user.phone),
              if (user.cnpj != null) _buildProfileItem('CNPJ', user.cnpj!),
              if (user.crmv != null) _buildProfileItem('CRMV', user.crmv!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navegar para tela de edição de perfil
            },
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurações'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notificações'),
              trailing: Switch(value: true, onChanged: null),
            ),
            ListTile(
              leading: Icon(Icons.dark_mode),
              title: Text('Tema Escuro'),
              trailing: Switch(value: false, onChanged: null),
            ),
            ListTile(
              leading: Icon(Icons.language),
              title: Text('Idioma'),
              trailing: Text('Português'),
            ),
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

  Future<bool> _showLogoutConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Saída'),
        content: const Text('Tem certeza que deseja sair do sistema?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  String _getUserTypeLabel(String userType) {
    switch (userType) {
      case 'ADMINISTRADOR':
        return 'Administrador';
      case 'LOJISTA':
        return 'Lojista';
      case 'TUTOR':
        return 'Tutor';
      case 'VETERINARIO':
        return 'Veterinário';
      default:
        return userType;
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}