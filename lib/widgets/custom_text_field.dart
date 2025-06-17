import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final bool obscureText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final void Function()? onTap;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? helperText;
  final bool required;
  final EdgeInsets? contentPadding;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.helperText,
    this.required = false,
    this.contentPadding,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          RichText(
            text: TextSpan(
              text: widget.label,
              style: Theme.of(context).textTheme.labelLarge,
              children: [
                if (widget.required)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          focusNode: _focusNode,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onSaved: widget.onSaved,
          onTap: widget.onTap,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            suffixIcon: _buildSuffixIcon(),
            helperText: widget.helperText,
            contentPadding: widget.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            counterText: '', // Remove o contador padrão
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    return widget.suffixIcon;
  }
}

// Campos específicos pré-configurados
class EmailField extends CustomTextField {
  EmailField({
    super.key,
    super.controller,
    super.initialValue,
    super.onChanged,
    super.onSaved,
    super.validator,
    super.enabled = true,
    super.required = true,
  }) : super(
          label: 'Email',
          hint: 'Digite seu email',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email),
        );
}

class PasswordField extends CustomTextField {
  PasswordField({
    super.key,
    super.controller,
    super.initialValue,
    super.onChanged,
    super.onSaved,
    super.validator,
    super.enabled = true,
    super.required = true,
    String? labelText,
    String? hintText,
  }) : super(
          label: labelText ?? 'Senha',
          hint: hintText ?? 'Digite sua senha',
          obscureText: true,
          prefixIcon: const Icon(Icons.lock),
        );
}

class PhoneField extends CustomTextField {
  PhoneField({
    super.key,
    super.controller,
    super.initialValue,
    super.onChanged,
    super.onSaved,
    super.validator,
    super.enabled = true,
    super.required = true,
  }) : super(
          label: 'Telefone',
          hint: '(00) 00000-0000',
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
            _PhoneInputFormatter(),
          ],
        );
}

class CNPJField extends CustomTextField {
  CNPJField({
    super.key,
    super.controller,
    super.initialValue,
    super.onChanged,
    super.onSaved,
    super.validator,
    super.enabled = true,
    super.required = false,
  }) : super(
          label: 'CNPJ',
          hint: '00.000.000/0000-00',
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.business),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(14),
            _CNPJInputFormatter(),
          ],
        );
}

class CRMVField extends CustomTextField {
  CRMVField({
    super.key,
    super.controller,
    super.initialValue,
    super.onChanged,
    super.onSaved,
    super.validator,
    super.enabled = true,
    super.required = true,
  }) : super(
          label: 'CRMV',
          hint: 'Digite seu CRMV',
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.medical_services),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        );
}

class PriceField extends CustomTextField {
  PriceField({
    super.key,
    super.controller,
    super.initialValue,
    super.onChanged,
    super.onSaved,
    super.validator,
    super.enabled = true,
    super.required = true,
    String? labelText,
  }) : super(
          label: labelText ?? 'Preço',
          hint: 'R\$ 0,00',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          prefixIcon: const Icon(Icons.attach_money),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            _CurrencyInputFormatter(),
          ],
        );
}

class WeightField extends CustomTextField {
  WeightField({
    super.key,
    super.controller,
    super.initialValue,
    super.onChanged,
    super.onSaved,
    super.validator,
    super.enabled = true,
    super.required = true,
  }) : super(
          label: 'Peso (kg)',
          hint: '0.0',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          prefixIcon: const Icon(Icons.monitor_weight),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
        );
}

// Formatadores de entrada
class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    if (text.length <= 2) {
      return newValue;
    } else if (text.length <= 7) {
      return newValue.copyWith(
        text: '(${text.substring(0, 2)}) ${text.substring(2)}',
        selection: TextSelection.collapsed(offset: text.length + 4),
      );
    } else if (text.length <= 11) {
      return newValue.copyWith(
        text: '(${text.substring(0, 2)}) ${text.substring(2, 7)}-${text.substring(7)}',
        selection: TextSelection.collapsed(offset: text.length + 5),
      );
    } else {
      return oldValue;
    }
  }
}

class _CNPJInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    if (text.length <= 2) {
      return newValue;
    } else if (text.length <= 5) {
      return newValue.copyWith(
        text: '${text.substring(0, 2)}.${text.substring(2)}',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    } else if (text.length <= 8) {
      return newValue.copyWith(
        text: '${text.substring(0, 2)}.${text.substring(2, 5)}.${text.substring(5)}',
        selection: TextSelection.collapsed(offset: text.length + 2),
      );
    } else if (text.length <= 12) {
      return newValue.copyWith(
        text: '${text.substring(0, 2)}.${text.substring(2, 5)}.${text.substring(5, 8)}/${text.substring(8)}',
        selection: TextSelection.collapsed(offset: text.length + 3),
      );
    } else if (text.length <= 14) {
      return newValue.copyWith(
        text: '${text.substring(0, 2)}.${text.substring(2, 5)}.${text.substring(5, 8)}/${text.substring(8, 12)}-${text.substring(12)}',
        selection: TextSelection.collapsed(offset: text.length + 4),
      );
    } else {
      return oldValue;
    }
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    double value = double.parse(text) / 100;
    String formatted = 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
    
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}