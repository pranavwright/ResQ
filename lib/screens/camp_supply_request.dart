import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/supply_request.dart';
import 'package:resq/widgets/supplyrequestdialog.dart';


class CampSupplyRequestScreen extends StatefulWidget {
  final String campId; // Pass the campId from your dashboard

  const CampSupplyRequestScreen({Key? key, required this.campId}) : super(key: key);

  @override
  _CampSupplyRequestScreenState createState() => _CampSupplyRequestScreenState();
}

class _CampSupplyRequestScreenState extends State<CampSupplyRequestScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<SupplyRequest> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final snapshot = await _firestore
          .collection('supplyRequests')
          .where('campId', isEqualTo: widget.campId)
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _requests = snapshot.docs.map((doc) => SupplyRequest.fromFirestore(doc)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load requests: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Supply Requests'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddRequestDialog(),
            tooltip: 'Add new request',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRequests,
              child: _requests.isEmpty
                  ? Center(child: Text('No requests yet. Add your first request.'))
                  : ListView.builder(
                      itemCount: _requests.length,
                      itemBuilder: (context, index) => _buildRequestItem(_requests[index]),
                    ),
            ),
    );
  }

  Widget _buildRequestItem(SupplyRequest request) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(request.itemName, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text('${request.quantity} ${request.unit}'),
            SizedBox(height: 4),
            Row(
              children: [
                _buildPriorityChip(request.priority),
                SizedBox(width: 8),
                _buildStatusChip(int.parse(request.status)),
              ],
            ),
            if (request.notes.isNotEmpty) ...[
              SizedBox(height: 8),
              Text('Notes: ${request.notes}', style: TextStyle(fontStyle: FontStyle.italic)),
            ],
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit, color: Colors.blue),
          onPressed: () => _showEditDialog(request),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(int priority) {
    final Map<int, Map<String, dynamic>> priorityData = {
      1: {'label': 'Critical', 'color': Colors.red},
      2: {'label': 'High', 'color': Colors.orange},
      3: {'label': 'Medium', 'color': Colors.blue},
      4: {'label': 'Low', 'color': Colors.green},
    };

    return Chip(
      label: Text(priorityData[priority]?['label'] ?? 'Unknown'),
      backgroundColor: priorityData[priority]?['color']?.withOpacity(0.2),
      labelStyle: TextStyle(
        color: priorityData[priority]?['color'],
        fontWeight: FontWeight.bold,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildStatusChip(int status) {
    final Map<int, Map<String, dynamic>> statusData = {
      0: {'label': 'Requested', 'color': Colors.grey},
      1: {'label': 'Approved', 'color': Colors.blue},
      2: {'label': 'In Transit', 'color': Colors.purple},
      3: {'label': 'Delivered', 'color': Colors.green},
      4: {'label': 'Cancelled', 'color': Colors.red},
    };

    return Chip(
      label: Text(statusData[status]?['label'] ?? 'Unknown'),
      backgroundColor: statusData[status]?['color']?.withOpacity(0.2),
      labelStyle: TextStyle(
        color: statusData[status]?['color'],
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _showAddRequestDialog() {
    showDialog(
      context: context,
      builder: (context) => SupplyRequestDialog(
        campId: widget.campId,
        onSubmitted: (request) async {
          await _loadRequests();
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showEditDialog(SupplyRequest request) {
    showDialog(
      context: context,
      builder: (context) => SupplyRequestDialog(
        campId: widget.campId,
        request: request,
        onSubmitted: (request) async {
          await _loadRequests();
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }
}