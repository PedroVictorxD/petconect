import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/product.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../../utils/constants.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? product;
  final Function(Product) onSaved;

  const ProductFormDialog({
    super.key,
    this.product,
    required this.onSaved,
  });

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  String _selectedUnit = Constants.measurementUnits[0];
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.product != null;
    
    if (_isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final product = widget.product!;
    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _priceController.text = product.price.toStringAsFixed(2).replaceAll('.', ',');
    _imageUrlController.text = product.imageUrl ?? '';
    _selectedUnit = product.measurementUnit;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _isEditing ? Icons.edit : Icons.add,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Text(_isEditing ? 'Editar Produto' : 'Novo Produto'),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nome do produto
                CustomTextField(
                  label: 'Nome do Produto',
                  controller: _nameController,
                  validator: Validators.validateName,
                  hint: 'Digite o nome do produto',
                  prefixIcon: const Icon(Icons.shopping_bag),
                  required: true,
                ),
                
                const SizedBox(height: 16),
                
                // Descrição
                CustomTextField(
                  label: 'Descrição',
                  controller: _descriptionController,
                  validator: Validators.validateDescription,
                  hint: 'Descreva o produto',
                  prefixIcon: const Icon(Icons.description),
                  maxLines: 3,
                ),
                
                const SizedBox(height: 16),
                
                // Preço e unidade de medida
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: PriceField(
                        controller: _priceController,
                        validator: Validators.validatePrice,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unidade *',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedUnit,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.straighten),
                            ),
                            items: Constants.measurementUnits.map((unit) {
                              return DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedUnit = value!;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Selecione uma unidade';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // URL da imagem (opcional)
                CustomTextField(
                  label: 'URL da Imagem',
                  controller: _imageUrlController,
                  hint: 'https://exemplo.com/imagem.jpg',
                  prefixIcon: const Icon(Icons.image),
                  keyboardType: TextInputType.url,
                ),
                
                const SizedBox(height: 16),
                
                // Preview da imagem
                if (_imageUrlController.text.isNotEmpty)
                  _buildImagePreview(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        CustomButton(
          text: _isEditing ? 'Atualizar' : 'Salvar',
          onPressed: _isLoading ? null : _handleSave,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SafeImageWidget(
          imageUrl: _imageUrlController.text,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser!;
      
      final productData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': _parsePriceFromInput(_priceController.text),
        'measurementUnit': _selectedUnit,
        'ownerId': user.id,
      };

      // Adicionar URL da imagem se fornecida
      if (_imageUrlController.text.trim().isNotEmpty) {
        productData['imageUrl'] = _imageUrlController.text.trim();
      }

      final apiService = ApiService();
      Map<String, dynamic> response;

      if (_isEditing) {
        response = await apiService.updateProduct(
          widget.product!.id!,
          productData,
          token: authService.token,
        );
      } else {
        response = await apiService.createProduct(
          productData,
          token: authService.token,
        );
      }

      if (response['success'] == true && mounted) {
        final product = Product.fromJson(response['data']);
        widget.onSaved(product);
        
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing 
                  ? 'Produto atualizado com sucesso!' 
                  : 'Produto criado com sucesso!'
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        await ErrorDialog.show(
          context,
          message: _isEditing
              ? 'Erro ao atualizar produto. Tente novamente.'
              : 'Erro ao criar produto. Tente novamente.',
        );
      }
    } catch (e) {
      if (mounted) {
        await ErrorDialog.show(
          context,
          message: 'Erro ao salvar produto. Verifique sua conexão e tente novamente.',
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

  double _parsePriceFromInput(String input) {
    // Remove formatação e converte para double
    String cleanInput = input
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    
    return double.tryParse(cleanInput) ?? 0.0;
  }
}