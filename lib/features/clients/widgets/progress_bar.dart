import 'package:flutter/material.dart';
import '../../../theme/theme.dart';

class ProgressBar extends StatelessWidget {
  final double progress;
  final String? lastSavedTime;
  final DateTime? lastSaved;
  final bool isSaving;

  const ProgressBar({
    super.key,
    required this.progress,
    this.lastSavedTime,
    this.lastSaved,
    this.isSaving = false,
  });

  String? get _lastSavedText {
    if (lastSavedTime != null) return lastSavedTime;
    if (lastSaved != null) {
      final now = DateTime.now();
      final difference = now.difference(lastSaved!);
      
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(context.brandOrange),
                  minHeight: 8,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  color: context.brandOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          
          // Draft status
          if (_lastSavedText != null || isSaving) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (isSaving) ...[
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(context.brandOrange),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Saving...',
                    style: TextStyle(
                      color: context.brandOrange,
                      fontSize: 12,
                    ),
                  ),
                ] else ...[
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Last saved: $_lastSavedText',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
