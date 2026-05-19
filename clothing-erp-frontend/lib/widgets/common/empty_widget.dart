import 'package:flutter/material.dart';
import 'package:clothing_erp/config/theme.dart';

class EmptyWidget extends StatelessWidget {
  final String? message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyWidget({
    super.key,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppTheme.textHintColor,
            ),
            const SizedBox(height: 16),
            Text(
              message ?? '暂无数据',
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel ?? '添加'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
