// models/supply_request.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resq/utils/colors.dart';
import 'package:resq/models/supply_request.dart';

class SupplyRequest {
  final String id;
  final String campId; // Add campId to associate with specific camp
  final String type;
  final int quantity;
  final String unit; // Add unit field
  final DateTime requestedAt;
  final bool isUrgent;
  final int priority; // Change from bool to int (1-4)
  final String notes; // Add notes field
  String status; // Add status field ('pending', 'approved', 'rejected', 'fulfilled')
  final String itemName;

  factory SupplyRequest.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SupplyRequest(
      id: doc.id,
      campId: data['campId'] ?? '',
      type: data['type'] ?? '',
      quantity: data['quantity'] ?? 0,
      unit: data['unit'] ?? '',
      priority: data['priority'] ?? 4,
      status: data['status'] ?? 'pending',
      notes: data['notes'] ?? '',
      requestedAt: (data['timestamp'] as Timestamp).toDate(),
      itemName: data['itemName'] ?? '',
    );
  }

  SupplyRequest({
    required this.id,
    required this.campId,
    required this.type,
    required this.quantity,
    this.unit = 'units',
    required this.requestedAt,
    this.isUrgent = false,
    this.priority = 2, // Default to high priority
    this.notes = '',
    this.status = 'pending',
    required this.itemName,
  });

  // Add these methods for status management
  void approve() => status = 'approved';
  void reject() => status = 'rejected';
  void markFulfilled() => status = 'fulfilled';

  // Helper method to get priority text
  String get priorityText {
    switch (priority) {
      case 1: return 'Critical';
      case 2: return 'High';
      case 3: return 'Medium';
      case 4: return 'Low';
      default: return 'Unknown';
    }
  }

  // Helper method to get status color
  Color get statusColor {
    switch (status) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      case 'fulfilled': return Colors.blue;
      default: return Colors.orange;
    }
  }
  // Copy with method
  SupplyRequest copyWith({
    String? id,
    String? campId,
    String? itemName,
    int? quantity,
    String? unit,
    int? priority,
    String? notes,
    String? status,
    String? type,
    DateTime? requestedAt,
  }) {
    return SupplyRequest(
      id: id ?? this.id,
      campId: campId ?? this.campId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      type: type ?? this.type,
      requestedAt: requestedAt ?? this.requestedAt,
    );
  }
}