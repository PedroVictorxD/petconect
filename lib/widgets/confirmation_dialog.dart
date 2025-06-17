import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDangerous;
  final IconData? icon;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirmar',
    this.cancelText = 'Cancelar',
    this.onConfirm,
    this.onCancel,
    this.isDangerous = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: isDangerous 
                  ? Theme.of(context).colorScheme.error 
                  : Theme.of(context).primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: isDangerous 
                    ? Theme.of(context).colorScheme.error 
                    : null,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            onCancel?.call();
          },
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm?.call();
          },
          style: isDangerous
              ? ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                )
              : null,
          child: Text(confirmText),
        ),
      ],
    );
  }

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    bool isDangerous = false,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDangerous: isDangerous,
        icon: icon,
      ),
    );
  }
}

class DeleteConfirmationDialog extends ConfirmationDialog {
  const DeleteConfirmationDialog({
    super.key,
    required String itemName,
    String? customMessage,
  }) : super(
          title: 'Confirmar Exclusão',
          message: customMessage ?? 'Tem certeza que deseja excluir "$itemName"? Esta ação não pode ser desfeita.',
          confirmText: 'Excluir',
          cancelText: 'Cancelar',
          isDangerous: true,
          icon: Icons.delete_forever,
        );

  static Future<bool?> show(
    BuildContext context, {
    required String itemName,
    String? customMessage,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        itemName: itemName,
        customMessage: customMessage,
      ),
    );
  }
}

class SaveConfirmationDialog extends ConfirmationDialog {
  const SaveConfirmationDialog({
    super.key,
    String? customMessage,
  }) : super(
          title: 'Salvar Alterações',
          message: customMessage ?? 'Deseja salvar as alterações realizadas?',
          confirmText: 'Salvar',
          cancelText: 'Cancelar',
          icon: Icons.save,
        );

  static Future<bool?> show(
    BuildContext context, {
    String? customMessage,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => SaveConfirmationDialog(
        customMessage: customMessage,
      ),
    );
  }
}

class LogoutConfirmationDialog extends ConfirmationDialog {
  const LogoutConfirmationDialog({
    super.key,
  }) : super(
          title: 'Confirmar Saída',
          message: 'Tem certeza que deseja sair do sistema?',
          confirmText: 'Sair',
          cancelText: 'Cancelar',
          isDangerous: true,
          icon: Icons.logout,
        );

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const LogoutConfirmationDialog(),
    );
  }
}

class UnsavedChangesDialog extends StatelessWidget {
  final VoidCallback? onSave;
  final VoidCallback? onDiscard;
  final VoidCallback? onCancel;

  const UnsavedChangesDialog({
    super.key,
    this.onSave,
    this.onDiscard,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Row(
        children: [
          Icon(Icons.warning, color: Colors.orange, size: 28),
          SizedBox(width: 12),
          Text('Alterações não Salvas'),
        ],
      ),
      content: const Text(
        'Você tem alterações não salvas. O que deseja fazer?',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onCancel?.call();
          },
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDiscard?.call();
          },
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('Descartar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onSave?.call();
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Alterações não Salvas'),
          ],
        ),
        content: const Text(
          'Você tem alterações não salvas. O que deseja fazer?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('cancel'),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('discard'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Descartar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop('save'),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;

  const ErrorDialog({
    super.key,
    this.title = 'Erro',
    required this.message,
    this.buttonText = 'OK',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.error,
            color: Theme.of(context).colorScheme.error,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
      content: Text(message),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(buttonText),
        ),
      ],
    );
  }

  static Future<void> show(
    BuildContext context, {
    String title = 'Erro',
    required String message,
    String buttonText = 'OK',
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        buttonText: buttonText,
      ),
    );
  }
}

class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;

  const SuccessDialog({
    super.key,
    this.title = 'Sucesso',
    required this.message,
    this.buttonText = 'OK',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
      content: Text(message),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(buttonText),
        ),
      ],
    );
  }

  static Future<void> show(
    BuildContext context, {
    String title = 'Sucesso',
    required String message,
    String buttonText = 'OK',
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => SuccessDialog(
        title: title,
        message: message,
        buttonText: buttonText,
      ),
    );
  }
}