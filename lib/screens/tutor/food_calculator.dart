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

class FoodCalculator extends StatefulWidget {
  const FoodCalculator({super.key});

  @override
  State<FoodCalculator> createState() => _FoodCalculatorState();
}

class _FoodCalculatorState extends State<FoodCalculator> with TickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  
  List<Pet> _pets = [];
  List<Food> _savedFoods = [];
  bool _isLoading = true;

  // Controllers para calculadora
  final _brandController = TextEditingController();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _dailyAmountController = TextEditingController();
  final _daysController = TextEditingController();
  final _quantityController = TextEditingController();

  Pet? _selectedPet;
  Food? _selectedFood;
  String _calculationType = 'duration'; // 'duration' ou 'quantity'
  FoodCalculation? _lastCalculation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _brandController.dispose();
    _nameController.dispose();
    _typeController.dispose();
    _dailyAmountController.dispose();
    _daysController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Calculadora de Ração',
        showBackButton: true,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            // Header com informações
            _buildHeader(),
            
            // Tab bar
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.calculate), text: 'Calculadora'),
                  Tab(icon: Icon(Icons.inventory), text: 'Rações Salvas'),
                  Tab(icon: Icon(Icons.history), text: 'Histórico'),
                ],
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: AppTheme.primaryColor,
              ),
            ),
            
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCalculatorTab(),
                  _buildSavedFoodsTab(),
                  _buildHistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calculate,
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
                  'Calculadora de Ração',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Calcule a quantidade ideal de ração para seus pets',
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

  Widget _buildCalculatorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seleção do pet
          _buildPetSelection(),
          
          const SizedBox(height: 24),
          
          // Informações da ração
          _buildFoodInformation(),
          
          const SizedBox(height: 24),
          
          // Tipo de cálculo
          _buildCalculationType(),
          
          const SizedBox(height: 24),
          
          // Campos de entrada baseados no tipo
          _buildCalculationInputs(),
          
          const SizedBox(height: 32),
          
          // Botão calcular
          Center(
            child: CustomButton(
              text: 'Calcular',
              onPressed: _selectedPet != null ? _calculate : null,
              icon: Icons.calculate,
              width: 200,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Resultado
          if (_lastCalculation != null) _buildResult(),
        ],
      ),
    );
  }

  Widget _buildPetSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecione o Pet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_pets.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  border: Border.all(color: Colors.amber[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.amber[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Você precisa cadastrar pelo menos um pet para usar a calculadora.',
                        style: TextStyle(color: Colors.amber[700]),
                      ),
                    ),
                  ],
                ),
              )
            else
              DropdownButtonFormField<Pet>(
                value: _selectedPet,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.pets),
                  hintText: 'Escolha um pet',
                ),
                items: _pets.map((pet) {
                  return DropdownMenuItem(
                    value: pet,
                    child: Row(
                      children: [
                        Icon(
                          Icons.pets,
                          color: _getPetTypeColor(pet.type),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text('${pet.name} (${pet.formattedWeight})'),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (pet) {
                  setState(() {
                    _selectedPet = pet;
                    _lastCalculation = null;
                  });
                },
              ),
            
            if (_selectedPet != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: _getPetTypeColor(_selectedPet!.type),
                      child: Icon(
                        Icons.pets,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedPet!.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_selectedPet!.formattedWeight} • ${_selectedPet!.activityDescription}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFoodInformation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Informações da Ração',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_savedFoods.isNotEmpty)
                  TextButton(
                    onPressed: _showSavedFoodsDialog,
                    child: const Text('Usar Salva'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Marca',
                    controller: _brandController,
                    hint: 'Ex: Royal Canin',
                    prefixIcon: const Icon(Icons.business),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    label: 'Nome',
                    controller: _nameController,
                    hint: 'Ex: Adult',
                    prefixIcon: const Icon(Icons.label),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Tipo',
                    controller: _typeController,
                    hint: 'Ex: Adulto, Filhote',
                    prefixIcon: const Icon(Icons.category),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    label: 'Quantidade Diária (g/kg)',
                    controller: _dailyAmountController,
                    hint: 'Ex: 30',
                    prefixIcon: const Icon(Icons.straighten),
                    keyboardType: TextInputType.number,
                    validator: Validators.validateWeight,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            CustomButton(
              text: 'Salvar Ração',
              type: ButtonType.outlined,
              onPressed: _canSaveFood() ? _saveFood : null,
              icon: Icons.save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationType() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipo de Cálculo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Duração da Ração'),
                    subtitle: const Text('Quanto tempo vai durar'),
                    value: 'duration',
                    groupValue: _calculationType,
                    onChanged: (value) {
                      setState(() {
                        _calculationType = value!;
                        _lastCalculation = null;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Quantidade Necessária'),
                    subtitle: const Text('Quanto comprar'),
                    value: 'quantity',
                    groupValue: _calculationType,
                    onChanged: (value) {
                      setState(() {
                        _calculationType = value!;
                        _lastCalculation = null;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationInputs() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _calculationType == 'duration' 
                  ? 'Quantidade de Ração Disponível'
                  : 'Período Desejado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_calculationType == 'duration')
              CustomTextField(
                label: 'Quantidade (kg)',
                controller: _quantityController,
                hint: 'Ex: 15',
                prefixIcon: const Icon(Icons.monitor_weight),
                keyboardType: TextInputType.number,
                validator: Validators.validateWeight,
              )
            else
              CustomTextField(
                label: 'Número de Dias',
                controller: _daysController,
                hint: 'Ex: 30',
                prefixIcon: const Icon(Icons.calendar_today),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Número de dias é obrigatório';
                  }
                  final days = int.tryParse(value);
                  if (days == null || days <= 0) {
                    return 'Número de dias inválido';
                  }
                  return null;
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green[600],
              size: 48,
            ),
            const SizedBox(height: 16),
            
            Text(
              'Resultado do Cálculo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            
            const SizedBox(height: 16),
            
            if (_calculationType == 'duration') ...[
              _buildResultItem(
                'Quantidade Diária',
                _lastCalculation!.formattedDailyAmount,
                Icons.today,
              ),
              _buildResultItem(
                'Duração Total',
                '${_lastCalculation!.durationInDays} dias',
                Icons.calendar_month,
              ),
            ] else ...[
              _buildResultItem(
                'Quantidade Diária',
                _lastCalculation!.formattedDailyAmount,
                Icons.today,
              ),
              _buildResultItem(
                'Quantidade Total',
                _lastCalculation!.formattedTotalAmount,
                Icons.shopping_cart,
              ),
              _buildResultItem(
                'Sugestão de Compra',
                '${_lastCalculation!.totalAmountInKg} kg',
                Icons.store,
              ),
            ],
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Novo Cálculo',
                    type: ButtonType.outlined,
                    onPressed: _resetCalculation,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Salvar Resultado',
                    onPressed: _saveCalculation,
                    icon: Icons.save,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedFoodsTab() {
    return _savedFoods.isEmpty
        ? _buildEmptyState('Nenhuma ração salva', 'Salve rações usadas frequentemente para cálculos rápidos')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _savedFoods.length,
            itemBuilder: (context, index) {
              return _buildSavedFoodCard(_savedFoods[index]);
            },
          );
  }

  Widget _buildHistoryTab() {
    return _buildEmptyState(
      'Histórico de Cálculos',
      'Seus cálculos salvos aparecerão aqui'
    );
  }

  Widget _buildSavedFoodCard(Food food) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.inventory, color: AppTheme.primaryColor),
        ),
        title: Text(
          food.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${food.recommendedDailyAmount}g por kg de peso'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'use':
                _useSavedFood(food);
                break;
              case 'delete':
                _deleteSavedFood(food);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'use',
              child: ListTile(
                leading: Icon(Icons.play_arrow),
                title: Text('Usar'),
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

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calculate_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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

  bool _canSaveFood() {
    return _brandController.text.isNotEmpty &&
           _nameController.text.isNotEmpty &&
           _typeController.text.isNotEmpty &&
           _dailyAmountController.text.isNotEmpty;
  }

  void _calculate() {
    if (_selectedPet == null) return;

    final dailyAmount = double.tryParse(_dailyAmountController.text.replaceAll(',', '.'));
    if (dailyAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quantidade diária inválida'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final pet = _selectedPet!;
    final food = Food(
      brand: _brandController.text.trim(),
      name: _nameController.text.trim(),
      type: _typeController.text.trim(),
      recommendedDailyAmount: dailyAmount,
      ownerId: 0,
    );

    // Calcular quantidade diária baseada no peso do pet
    double dailyAmountForPet = (pet.weight * dailyAmount);

    // Ajustar baseado no nível de atividade
    switch (pet.activityLevel) {
      case 'BAIXA':
        dailyAmountForPet *= 0.8;
        break;
      case 'ALTA':
        dailyAmountForPet *= 1.2;
        break;
      case 'MUITO_ALTA':
        dailyAmountForPet *= 1.4;
        break;
      default: // MODERADA
        break;
    }

    int durationInDays;

    if (_calculationType == 'duration') {
      final quantity = double.tryParse(_quantityController.text.replaceAll(',', '.'));
      if (quantity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quantidade inválida'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      durationInDays = ((quantity * 1000) / dailyAmountForPet).floor();
    } else {
      final days = int.tryParse(_daysController.text);
      if (days == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Número de dias inválido'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      durationInDays = days;
    }

    setState(() {
      _lastCalculation = FoodCalculation(
        pet: pet,
        food: food,
        dailyAmount: dailyAmountForPet,
        durationInDays: durationInDays,
      );
    });
  }

  void _saveFood() {
    final food = Food(
      brand: _brandController.text.trim(),
      name: _nameController.text.trim(),
      type: _typeController.text.trim(),
      recommendedDailyAmount: double.tryParse(_dailyAmountController.text.replaceAll(',', '.')) ?? 0,
      ownerId: 0,
    );

    setState(() {
      _savedFoods.add(food);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ração salva com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _saveCalculation() {
    // Implementar salvamento do cálculo no backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cálculo salvo no histórico!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _resetCalculation() {
    setState(() {
      _lastCalculation = null;
      _quantityController.clear();
      _daysController.clear();
    });
  }

  void _showSavedFoodsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rações Salvas'),
        content: SizedBox(
          width: 300,
          height: 400,
          child: ListView.builder(
            itemCount: _savedFoods.length,
            itemBuilder: (context, index) {
              final food = _savedFoods[index];
              return ListTile(
                title: Text(food.fullName),
                subtitle: Text('${food.recommendedDailyAmount}g/kg'),
                onTap: () {
                  _useSavedFood(food);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _useSavedFood(Food food) {
    setState(() {
      _brandController.text = food.brand;
      _nameController.text = food.name;
      _typeController.text = food.type;
      _dailyAmountController.text = food.recommendedDailyAmount.toString();
      _selectedFood = food;
    });

    _tabController.animateTo(0); // Voltar para a calculadora
  }

  void _deleteSavedFood(Food food) {
    setState(() {
      _savedFoods.remove(food);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ração removida'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _loadData() async {
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
}