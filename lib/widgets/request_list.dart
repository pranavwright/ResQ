// widgets/request_list.dart
import 'package:flutter/material.dart';
import '../models/supply_request.dart';
import '../utils/colors.dart';

class RequestList extends StatelessWidget {
  final List<SupplyRequest> requests;
  final Function(SupplyRequest)? onApprove;
  final Function(SupplyRequest)? onReject;

  const RequestList({
    required this.requests,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Supply Requests',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Spacer(),
                Chip(
                  label: Text('${requests.length} total'),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...requests.map((request) => _buildRequestItem(context, request)),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestItem(BuildContext context, SupplyRequest request) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      color: request.isUrgent ? AppColors.alert.withOpacity(0.05) : null,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: request.statusColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getRequestIcon(request),
            color: request.statusColor,
          ),
        ),
        title: Text(
          request.type,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: request.isUrgent ? AppColors.alert : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${request.quantity} ${request.unit}'),
            SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(request.priorityText),
                  backgroundColor: _getPriorityColor(request.priority).withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: _getPriorityColor(request.priority),
                  ),
                ),
                SizedBox(width: 8),
                if (request.isUrgent)
                  Chip(
                    label: Text('URGENT'),
                    backgroundColor: AppColors.alert.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: AppColors.alert,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            if (request.notes.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                request.notes,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onApprove != null && request.status == 'pending')
              IconButton(
                icon: Icon(Icons.check, color: AppColors.success),
                onPressed: () => onApprove!(request),
              ),
            if (onReject != null && request.status == 'pending')
              IconButton(
                icon: Icon(Icons.close, color: AppColors.alert),
                onPressed: () => onReject!(request),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getRequestIcon(SupplyRequest request) {
    switch (request.type) {
      case 'Water': return Icons.water_drop;
      case 'Food': return Icons.fastfood;
      case 'Medicines': return Icons.medical_services;
      case 'First Aid Kits': return Icons.medical_services;
      case 'Blankets': return Icons.king_bed;
      case 'Tents': return Icons.account_balance;
      default: return Icons.inventory;
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1: return Colors.red;
      case 2: return Colors.orange;
      case 3: return Colors.blue;
      case 4: return Colors.green;
      default: return Colors.grey;
    }
  }
}