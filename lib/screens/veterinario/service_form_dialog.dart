import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../utils/validators.dart';
import '../../theme/app_theme.dart';

class ServiceFormDialog extends StatefulWidget {
  final VetService? service;
  final Function(VetService) onSaved;

  const ServiceFormDialog({
    super.key,
    this.service,
    required this.onSaved,
  });

  @override
  State<ServiceFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends State<ServiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditing = false;

  // Lista de serviços veterinários comuns para sugestões
  final List<String> _commonServices = [
    'Consulta de Rotina',
    'Vacinação',
    'Castração',
    'Cirurgia Geral',
    'Exames Laboratoriais',
    'Radiografia',
    'Ultrassonografia',
    'Emergência 24h',
    'Consulta Domiciliar',
    'Microchipagem',
    'Limpeza Dentária',
    'Cirurgia Ortopédica',
    'Dermatologia Veterinária',
    'Cardiologia Veterinária',
    'Oftalmologia Veterinária',
    'Acupuntura Veterinária',
    'Fisioterapia Animal',
    'Internação',
    'Banho e Tosa',
    'Eutanásia Humanitária',
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.service != null;
    
    if (_isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final service = widget.service!;
    _nameController.text = service.name;
    _descriptionController.text = service.description;
    _priceController.text = service.price.toStringAsFixed(2).replaceAll('.', ',');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _isEditing ? Icons.edit : Icons.add,
            color: AppTheme.getUserTypeColor('veterinario'),
          ),
          const SizedBox(width: 8),
          Text(_isEditing ? 'Editar Serviço' : 'Novo Serviço'),
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
                // Nome do serviço com sugestões
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      label: 'Nome do Serviço',
                      controller: _nameController,
                      validator: Validators.validateName,
                      hint: 'Digite o nome do serviço',
                      prefixIcon: const Icon(Icons.medical_services),
                      required: true,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Sugestões de serviços
                    Text(
                      'Sugestões:',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _commonServices.take(6).map((serviceName) {
                        return ActionChip(
                          label: Text(
                            serviceName,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onPressed: () {
                            _nameController.text = serviceName;
                            _generateDescription(serviceName);
                          },
                          backgroundColor: AppTheme.getUserTypeColor('veterinario').withOpacity(0.1),
                          side: BorderSide(
                            color: AppTheme.getUserTypeColor('veterinario').withOpacity(0.3),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    if (_commonServices.length > 6) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _showAllSuggestions,
                        child: const Text('Ver todas as sugestões'),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Descrição
                CustomTextField(
                  label: 'Descrição',
                  controller: _descriptionController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Descrição é obrigatória';
                    }
                    return Validators.validateDescription(value);
                  },
                  hint: 'Descreva o serviço oferecido',
                  prefixIcon: const Icon(Icons.description),
                  maxLines: 4,
                  required: true,
                ),
                
                const SizedBox(height: 16),
                
                // Preço
                PriceField(
                  labelText: 'Preço do Serviço',
                  controller: _priceController,
                  validator: Validators.validatePrice,
                ),
                
                const SizedBox(height: 16),
                
                // Informações adicionais
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue[700], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Dicas para um bom serviço',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildTipItem('Use nomes claros e específicos'),
                      _buildTipItem('Descreva o que está incluído'),
                      _buildTipItem('Mencione duração aproximada'),
                      _buildTipItem('Indique se é necessário agendamento'),
                    ],
                  ),
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

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 14,
            color: Colors.blue[600],
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _generateDescription(String serviceName) {
    // Gerar descrições automáticas baseadas no nome do serviço
    final descriptions = {
      'Consulta de Rotina': 'Exame clínico completo do animal, avaliação do estado geral de saúde, orientações preventivas e acompanhamento veterinário.',
      'Vacinação': 'Aplicação de vacinas essenciais para proteção contra doenças. Inclui orientações sobre calendário vacinal e cuidados pós-vacinação.',
      'Castração': 'Procedimento cirúrgico para esterilização. Inclui pré-operatório, cirurgia e acompanhamento pós-operatório.',
      'Cirurgia Geral': 'Procedimentos cirúrgicos diversos. Avaliação pré-operatória, cirurgia e cuidados pós-operatórios inclusos.',
      'Exames Laboratoriais': 'Análises clínicas para diagnóstico. Coleta de material, processamento e entrega de resultados com interpretação.',
      'Radiografia': 'Exame de imagem para diagnóstico de fraturas, problemas internos e avaliação de órgãos.',
      'Ultrassonografia': 'Exame de ultrassom para avaliação de órgãos internos, gestação e diagnósticos diversos.',
      'Emergência 24h': 'Atendimento veterinário de urgência e emergência. Disponível 24 horas para casos críticos.',
      'Consulta Domiciliar': 'Atendimento veterinário no conforto da sua casa. Ideal para animais estressados ou com dificuldade de locomoção.',
      'Microchipagem': 'Implante de microchip para identificação permanente do animal. Procedimento rápido e seguro.',
      'Limpeza Dentária': 'Profilaxia dental completa com remoção de tártaro e orientações de higiene bucal.',
      'Cirurgia Ortopédica': 'Procedimentos cirúrgicos para correção de problemas ósseos e articulares.',
      'Dermatologia Veterinária': 'Diagnóstico e tratamento de problemas de pele, alergias e doenças dermatológicas.',
      'Cardiologia Veterinária': 'Avaliação e tratamento de problemas cardíacos. Inclui eletrocardiograma quando necessário.',
      'Oftalmologia Veterinária': 'Diagnóstico e tratamento de problemas oculares e doenças dos olhos.',
      'Acupuntura Veterinária': 'Tratamento complementar através de acupuntura para dor e bem-estar animal.',
      'Fisioterapia Animal': 'Reabilitação física para recuperação de cirurgias e tratamento de lesões.',
      'Internação': 'Cuidados intensivos e acompanhamento 24h para animais em tratamento.',
      'Banho e Tosa': 'Serviços de higiene e estética animal com produtos especializados.',
      'Eutanásia Humanitária': 'Procedimento humanitário realizado com dignidade e respeito ao animal e família.',
    };

    if (descriptions.containsKey(serviceName)) {
      _descriptionController.text = descriptions[serviceName]!;
    }
  }

  void _showAllSuggestions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Todos os Serviços'),
        content: SizedBox(
          width: 400,
          height: 400,
          child: ListView.builder(
            itemCount: _commonServices.length,
            itemBuilder: (context, index) {
              final serviceName = _commonServices[index];
              return ListTile(
                title: Text(serviceName),
                onTap: () {
                  _nameController.text = serviceName;
                  _generateDescription(serviceName);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
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
      
      final serviceData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': _parsePriceFromInput(_priceController.text),
        'ownerId': user.id,
      };

      final apiService = ApiService();
      Map<String, dynamic> response;

      if (_isEditing) {
        response = await apiService.updateService(
          widget.service!.id!,
          serviceData,
          token: authService.token,
        );
      } else {
        response = await apiService.createService(
          serviceData,
          token: authService.token,
        );
      }

      if (response['success'] == true && mounted) {
        final service = VetService.fromJson(response['data']);
        widget.onSaved(service);
        
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing 
                  ? 'Serviço atualizado com sucesso!' 
                  : 'Serviço criado com sucesso!'
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        await ErrorDialog.show(
          context,
          message: _isEditing
              ? 'Erro ao atualizar serviço. Tente novamente.'
              : 'Erro ao criar serviço. Tente novamente.',
        );
      }
    } catch (e) {
      if (mounted) {
        await ErrorDialog.show(
          context,
          message: 'Erro ao salvar serviço. Verifique sua conexão e tente novamente.',
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