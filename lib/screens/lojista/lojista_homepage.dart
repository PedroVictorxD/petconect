import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/product.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../theme/app_theme.dart';
import 'product_form_dialog.dart';

class LojistaHomepage extends StatefulWidget {
  const LojistaHomepage({super.key});

  @override
  State<LojistaHomepage> createState() => _LojistaHomepageState();
}

class _LojistaHomepageState extends State<LojistaHomepage> {
  final ApiService _apiService = ApiService();
  List<Product> _products = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Meus Produtos',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            // Header com estatísticas e busca
            _buildHeader(context, user, isDesktop),
            
            // Lista de produtos
            Expanded(
              child: _buildProductsList(context, isDesktop),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Novo Produto'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildHeader(BuildContext context, user, bool isDesktop) {
    final filteredProducts = _getFilteredProducts();
    
    return Container(
      padding: const EdgeInsets.all(20),
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
          // Estatísticas
          if (isDesktop)
            Row(
              children: [
                Expanded(child: _buildStatCard('Total de Produtos', _products.length.toString(), Icons.inventory)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Produtos Ativos', _products.length.toString(), Icons.check_circle)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Valor Médio', _calculateAveragePrice(), Icons.attach_money)),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: _buildStatCard('Total', _products.length.toString(), Icons.inventory)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Valor Médio', _calculateAveragePrice(), Icons.attach_money)),
              ],
            ),
          
          const SizedBox(height: 20),
          
          // Barra de busca
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar produtos...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
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

  Widget _buildProductsList(BuildContext context, bool isDesktop) {
    final filteredProducts = _getFilteredProducts();

    if (filteredProducts.isEmpty && !_isLoading) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: isDesktop
          ? _buildDesktopGrid(filteredProducts)
          : _buildMobileList(filteredProducts),
    );
  }

  Widget _buildDesktopGrid(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(products[index], isGrid: true);
      },
    );
  }

  Widget _buildMobileList(List<Product> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(products[index], isGrid: false);
      },
    );
  }

  Widget _buildProductCard(Product product, {required bool isGrid}) {
    return Card(
      elevation: 2,
      child: isGrid
          ? _buildGridProductCard(product)
          : _buildListProductCard(product),
    );
  }

  Widget _buildGridProductCard(Product product) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem do produto
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: product.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage();
                        },
                      ),
                    )
                  : _buildPlaceholderImage(),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Nome do produto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.formattedPrice,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Editar',
                        type: ButtonType.outlined,
                        onPressed: () => _showProductDialog(context, product: product),
                        height: 32,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomButton(
                        text: 'Excluir',
                        type: ButtonType.danger,
                        onPressed: () => _confirmDelete(product),
                        height: 32,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListProductCard(Product product) {
    return ListTile(
      leading: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: product.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderImage();
                  },
                ),
              )
            : _buildPlaceholderImage(),
      ),
      title: Text(
        product.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.description,
            maxLines: 1,
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
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'edit':
              _showProductDialog(context, product: product);
              break;
            case 'delete':
              _confirmDelete(product);
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
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image,
        color: Colors.grey[400],
        size: 40,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 120,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isNotEmpty
                ? 'Nenhum produto encontrado'
                : 'Nenhum produto cadastrado',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'Tente buscar por outro termo'
                : 'Cadastre seu primeiro produto para começar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (_searchQuery.isEmpty)
            CustomButton(
              text: 'Cadastrar Primeiro Produto',
              onPressed: () => _showProductDialog(context),
              icon: Icons.add,
            ),
        ],
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

  String _calculateAveragePrice() {
    if (_products.isEmpty) return 'R\$ 0,00';
    
    double total = _products.fold(0, (sum, product) => sum + product.price);
    double average = total / _products.length;
    
    return 'R\$ ${average.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      
      if (user != null) {
        final response = await _apiService.getProducts(
          token: authService.token,
          ownerId: user.id,
        );

        if (response['success'] == true && mounted) {
          final List<dynamic> productsData = response['data'] ?? [];
          setState(() {
            _products = productsData.map((data) => Product.fromJson(data)).toList();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao carregar produtos'),
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

  void _showProductDialog(BuildContext context, {Product? product}) {
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        product: product,
        onSaved: (savedProduct) {
          _loadProducts(); // Recarregar lista após salvar
        },
      ),
    );
  }

  Future<void> _confirmDelete(Product product) async {
    final confirmed = await DeleteConfirmationDialog.show(
      context,
      itemName: product.name,
    );

    if (confirmed == true) {
      await _deleteProduct(product);
    }
  }

  Future<void> _deleteProduct(Product product) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final response = await _apiService.deleteProduct(
        product.id!,
        token: authService.token,
      );

      if (response['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produto excluído com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
        _loadProducts(); // Recarregar lista
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao excluir produto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao excluir produto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}