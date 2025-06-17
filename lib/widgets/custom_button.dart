import 'package:flutter/material.dart';

enum ButtonType { primary, secondary, outlined, text, danger }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final double? fontSize;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget button;
    
    switch (type) {
      case ButtonType.primary:
        button = _buildElevatedButton(context, theme);
        break;
      case ButtonType.secondary:
        button = _buildFilledButton(context, theme);
        break;
      case ButtonType.outlined:
        button = _buildOutlinedButton(context, theme);
        break;
      case ButtonType.text:
        button = _buildTextButton(context, theme);
        break;
      case ButtonType.danger:
        button = _buildDangerButton(context, theme);
        break;
    }

    return SizedBox(
      width: width,
      height: height ?? 48,
      child: button,
    );
  }

  Widget _buildElevatedButton(BuildContext context, ThemeData theme) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _buildButtonContent(theme.primaryColor),
    );
  }

  Widget _buildFilledButton(BuildContext context, ThemeData theme) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: theme.colorScheme.secondary,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _buildButtonContent(Colors.white),
    );
  }

  Widget _buildOutlinedButton(BuildContext context, ThemeData theme) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _buildButtonContent(theme.primaryColor),
    );
  }

  Widget _buildTextButton(BuildContext context, ThemeData theme) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: _buildButtonContent(theme.primaryColor),
    );
  }

  Widget _buildDangerButton(BuildContext context, ThemeData theme) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.error,
        foregroundColor: Colors.white,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _buildButtonContent(Colors.white),
    );
  }

  Widget _buildButtonContent(Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == ButtonType.outlined || type == ButtonType.text 
                ? textColor 
                : Colors.white,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize != null ? fontSize! + 2 : 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize ?? 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// Botões específicos pré-configurados
class LoadingButton extends CustomButton {
  const LoadingButton({
    super.key,
    required super.text,
    required super.onPressed,
    required bool loading,
    super.type = ButtonType.primary,
    super.icon,
    super.width,
    super.height,
  }) : super(isLoading: loading);
}

class CustomIconButton extends CustomButton {
  const CustomIconButton({
    super.key,
    required super.text,
    required super.onPressed,
    required IconData buttonIcon,
    super.type = ButtonType.primary,
    super.isLoading = false,
    super.width,
    super.height,
  }) : super(icon: buttonIcon);
}

class DangerButton extends CustomButton {
  const DangerButton({
    super.key,
    required super.text,
    required super.onPressed,
    super.isLoading = false,
    super.icon,
    super.width,
    super.height,
  }) : super(type: ButtonType.danger);
}