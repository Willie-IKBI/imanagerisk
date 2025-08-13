import 'package:flutter/material.dart';
import '../../../theme/theme.dart';
import '../../../shared/widgets/widgets.dart';

enum ClientType {
  personal,
  business,
  bodyCorporate,
}

extension ClientTypeExtension on ClientType {
  String get displayName {
    switch (this) {
      case ClientType.personal:
        return 'Personal Client';
      case ClientType.business:
        return 'Business Client';
      case ClientType.bodyCorporate:
        return 'Body Corporate';
    }
  }

  String get subtitle {
    switch (this) {
      case ClientType.personal:
        return 'Individual person with ID number';
      case ClientType.business:
        return 'Company with registration number';
      case ClientType.bodyCorporate:
        return 'Sectional title scheme';
    }
  }

  IconData get icon {
    switch (this) {
      case ClientType.personal:
        return Icons.person;
      case ClientType.business:
        return Icons.business;
      case ClientType.bodyCorporate:
        return Icons.apartment;
    }
  }
}

class ClientTypeSelector extends StatelessWidget {
  final ClientType? selectedType;
  final ValueChanged<ClientType> onTypeSelected;

  const ClientTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What type of client are you adding?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        
        // Client type options
        ...ClientType.values.map((type) => _buildTypeOption(context, type)),
      ],
    );
  }

  Widget _buildTypeOption(BuildContext context, ClientType type) {
    final isSelected = selectedType == type;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => onTypeSelected(type),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected 
                ? context.brandOrange.withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? context.brandOrange
                  : Colors.white.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? context.brandOrange
                      : Colors.grey[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  type.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.displayName,
                      style: TextStyle(
                        color: isSelected 
                            ? context.brandOrange
                            : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type.subtitle,
                      style: TextStyle(
                        color: isSelected 
                            ? context.brandOrange.withOpacity(0.8)
                            : Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Radio button
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected 
                        ? context.brandOrange
                        : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.brandOrange,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
