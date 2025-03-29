// lib/widgets/urgent_actions.dart
import 'package:flutter/material.dart';
import '../models/supply_request.dart';
import 'package:resq/utils/colors.dart';
class UrgentActions extends StatelessWidget {
  final List<SupplyRequest> requests;

  const UrgentActions({required this.requests});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) return SizedBox();

    return Card(
      color: AppColors.alert.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: AppColors.alert),
                SizedBox(width: 8),
                Text('Urgent Actions Needed', style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.alert,
                )),
              ],
            ),
            SizedBox(height: 8),
            ...requests.map((request) => ListTile(
              title: Text('${request.type} × ${request.quantity}'),
              subtitle: Text('High priority - ${request.status}'),
              trailing: Wrap(
                spacing: 8,
                children: [
                  ElevatedButton(
                    child: Text('Approve'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                    onPressed: () => _showApprovalDialog(context, request, true),
                  ),
                  OutlinedButton(
                    child: Text('Reject'),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.alert),
                    onPressed: () => _showApprovalDialog(context, request, false),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showApprovalDialog(BuildContext context, SupplyRequest request, bool isApprove) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isApprove ? 'Approve Request?' : 'Reject Request?'),
        content: Text('${request.type} × ${request.quantity}\n\nReason (optional):'),
        actions: [
          TextField(decoration: InputDecoration(hintText: 'Enter reason...')),
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text(isApprove ? 'Confirm Approval' : 'Confirm Rejection'),
            onPressed: () {
              if (isApprove) {
                request.approve();
              } else {
                request.reject();
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isApprove 
                  ? '✅ Request approved' 
                  : '❌ Request rejected')),
              );
            },
          ),
        ],
      ),
    );
  }
}