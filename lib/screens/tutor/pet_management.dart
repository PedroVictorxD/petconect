import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/pet.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../../utils/constants.dart';

class PetManagement extends StatefulWidget {
  const PetManagement({super.key});

  @override
  State<PetManagement> createState() => _PetManagementState();
}

class _PetManagementState extends State<PetManagement> {
  final ApiService _apiService = ApiService();
  List<Pet> _pets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Gerenciar Pets',
        showBackButton: true,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: _pets.isEmpty ? _buildEmptyState() : _buildPetsList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPetDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Pet'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 120,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum pet cadastrado',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Adicione informações sobre seus pets para usar a calculadora de ração e outras funcionalidades.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Adicionar Primeiro Pet',
            onPressed: () => _showPetDialog(context),
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  Widget _buildPetsList() {
    return RefreshIndicator(
      onRefresh: _loadPets,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pets.length,
        itemBuilder: (context, index) {
          return _buildPetCard(_pets[index]);
        },
      ),
    );
  }

  Widget _buildPetCard(Pet pet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: _getPetTypeColor(pet.type),
                  child: Icon(
                    _getPetTypeIcon(pet.type),
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${pet.typeDescription} • ${pet.ageDescription}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      if (pet.breed != null)
                        Text(
                          pet.breed!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showPetDialog(context, pet: pet);
                        break;
                      case 'delete':
                        _confirmDelete(pet);
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
            const SizedBox(height: 16),
            
            // Informações detalhadas
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem('Peso', pet.formattedWeight, Icons.monitor_weight),
                      ),
                      Expanded(
                        child: _buildInfoItem('Atividade', pet.activityDescription, Icons.directions_run),
                      ),
                    ],
                  ),
                  if (pet.notes != null && pet.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoItem('Observações', pet.notes!, Icons.note),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getPetTypeColor(String type) {
    switch (type) {
      case 'CACHORRO':
        return Colors.brown;
      case 'GATO':
        return Colors.orange;
      case 'PASSARO':
        return Colors.blue;
      case 'PEIXE':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  IconData _getPetTypeIcon(String type) {
    switch (type) {
      case 'CACHORRO':
      case 'GATO':
        return Icons.pets;
      case 'PASSARO':
        return Icons.flutter_dash;
      case 'PEIXE':
        return Icons.pool;
      default:
        return Icons.pets;
    }
  }

  void _showPetDialog(BuildContext context, {Pet? pet}) {
    showDialog(
      context: context,
      builder: (context) => _PetFormDialog(
        pet: pet,
        onSaved: (savedPet) {
          _loadPets(); // Recarregar lista após salvar
        },
      ),
    );
  }

  Future<void> _confirmDelete(Pet pet) async {
    final confirmed = await DeleteConfirmationDialog.show(
      context,
      itemName: pet.name,
    );

    if (confirmed == true) {
      await _deletePet(pet);
    }
  }

  Future<void> _deletePet(Pet pet) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final response = await _apiService.deletePet(
        pet.id!,
        token: authService.token,
      );

      if (response['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pet excluído com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
        _loadPets(); // Recarregar lista
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao excluir pet'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao excluir pet'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadPets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      
      if (user != null) {
        final response = await _apiService.getPets(
          token: authService.token,
          ownerId: user.id,
        );

        if (response['success'] == true && mounted) {
          final List<dynamic> petsData = response['data'] ?? [];
          setState(() {
            _pets = petsData.map((data) => Pet.fromJson(data)).toList();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao carregar pets'),
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
}

class _PetFormDialog extends StatefulWidget {
  final Pet? pet;
  final Function(Pet) onSaved;

  const _PetFormDialog({
    this.pet,
    required this.onSaved,
  });

  @override
  State<_PetFormDialog> createState() => _PetFormDialogState();
}

class _PetFormDialogState extends State<_PetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  final _breedController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedType = Constants.petTypes[0];
  String _selectedActivity = Constants.activityLevels[1];
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.pet != null;
    
    if (_isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final pet = widget.pet!;
    _nameController.text = pet.name;
    _weightController.text = pet.weight.toString();
    _ageController.text = pet.age.toString();
    _breedController.text = pet.breed ?? '';
    _notesController.text = pet.notes ?? '';
    _selectedType = pet.type;
    _selectedActivity = pet.activityLevel;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _breedController.dispose();
    _notesController.dispose();
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
          Text(_isEditing ? 'Editar Pet' : 'Novo Pet'),
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
                // Nome do pet
                CustomTextField(
                  label: 'Nome do Pet',
                  controller: _nameController,
                  validator: Validators.validateName,
                  hint: 'Digite o nome do seu pet',
                  prefixIcon: const Icon(Icons.pets),
                  required: true,
                ),
                
                const SizedBox(height: 16),
                
                // Tipo do pet
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipo *',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: Constants.petTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getPetTypeLabel(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecione um tipo';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Peso e idade
                Row(
                  children: [
                    Expanded(
                      child: WeightField(
                        controller: _weightController,
                        validator: Validators.validateWeight,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Idade (anos)',
                        controller: _ageController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Idade é obrigatória';
                          }
                          final age = int.tryParse(value);
                          if (age == null || age < 0 || age > 30) {
                            return 'Idade inválida';
                          }
                          return null;
                        },
                        hint: '0',
                        prefixIcon: const Icon(Icons.cake),
                        keyboardType: TextInputType.number,
                        required: true,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Nível de atividade
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nível de Atividade *',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedActivity,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.directions_run),
                      ),
                      items: Constants.activityLevels.map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(_getActivityLabel(level)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedActivity = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecione um nível';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Raça (opcional)
                CustomTextField(
                  label: 'Raça',
                  controller: _breedController,
                  hint: 'Digite a raça (opcional)',
                  prefixIcon: const Icon(Icons.info),
                ),
                
                const SizedBox(height: 16),
                
                // Observações (opcional)
                CustomTextField(
                  label: 'Observações',
                  controller: _notesController,
                  hint: 'Informações adicionais sobre o pet',
                  prefixIcon: const Icon(Icons.note),
                  maxLines: 3,
                ),
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

  String _getPetTypeLabel(String type) {
    switch (type) {
      case 'CACHORRO':
        return 'Cachorro';
      case 'GATO':
        return 'Gato';
      case 'PASSARO':
        return 'Pássaro';
      case 'PEIXE':
        return 'Peixe';
      default:
        return 'Outro';
    }
  }

  String _getActivityLabel(String level) {
    switch (level) {
      case 'BAIXA':
        return 'Baixa atividade';
      case 'MODERADA':
        return 'Atividade moderada';
      case 'ALTA':
        return 'Alta atividade';
      case 'MUITO_ALTA':
        return 'Muito ativa';
      default:
        return level;
    }
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
      
      final petData = {
        'name': _nameController.text.trim(),
        'type': _selectedType,
        'weight': double.parse(_weightController.text.replaceAll(',', '.')),
        'age': int.parse(_ageController.text),
        'activityLevel': _selectedActivity,
        'ownerId': user.id,
      };

      // Adicionar campos opcionais se preenchidos
      if (_breedController.text.trim().isNotEmpty) {
        petData['breed'] = _breedController.text.trim();
      }
      
      if (_notesController.text.trim().isNotEmpty) {
        petData['notes'] = _notesController.text.trim();
      }

      final apiService = ApiService();
      Map<String, dynamic> response;

      if (_isEditing) {
        response = await apiService.updatePet(
          widget.pet!.id!,
          petData,
          token: authService.token,
        );
      } else {
        response = await apiService.createPet(
          petData,
          token: authService.token,
        );
      }

      if (response['success'] == true && mounted) {
        final pet = Pet.fromJson(response['data']);
        widget.onSaved(pet);
        
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing 
                  ? 'Pet atualizado com sucesso!' 
                  : 'Pet adicionado com sucesso!'
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        await ErrorDialog.show(
          context,
          message: _isEditing
              ? 'Erro ao atualizar pet. Tente novamente.'
              : 'Erro ao adicionar pet. Tente novamente.',
        );
      }
    } catch (e) {
      if (mounted) {
        await ErrorDialog.show(
          context,
          message: 'Erro ao salvar pet. Verifique sua conexão e tente novamente.',
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
}