import 'package:flutter/material.dart';
import '../models/supply_request.dart';
import 'package:resq/widgets/supplyrequestdialog.dart';

class CampSupplyRequestScreen extends StatefulWidget {
  final String campId;

  const CampSupplyRequestScreen({Key? key, required this.campId}) : super(key: key);

  @override
  _CampSupplyRequestScreenState createState() => _CampSupplyRequestScreenState();
}

class _CampSupplyRequestScreenState extends State<CampSupplyRequestScreen> {
  List<SupplyRequest> _requests = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialRequests();
  }

  void _loadInitialRequests() {
    setState(() {
      _requests = [
        SupplyRequest(
          id: '1',
          campId: widget.campId,
          itemName: 'Tents',
          quantity: 5,
          unit: 'pieces',
          priority: 2,
          notes: 'Urgently needed',
          status: '0',
          type: 'supply',
          requestedAt: DateTime.now(),
        ),
        SupplyRequest(
          id: '2',
          campId: widget.campId,
          itemName: 'Blankets',
          quantity: 20,
          unit: 'pieces',
          priority: 1,
          notes: 'For winter season',
          status: '0',
          type: 'supply',
          requestedAt: DateTime.now(),
        ),
      ];
    });
  }

  Future<void> _addRequest(SupplyRequest newRequest) async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay (remove in production)
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _requests = [
        ..._requests,
        newRequest.copyWith(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          requestedAt: DateTime.now(),
        ),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supply Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _isLoading ? null : _showAddRequestDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inventory, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No requests yet'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _showAddRequestDialog,
                        child: const Text('Add First Request'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    _loadInitialRequests();
                  },
                  child: ListView.builder(
                    itemCount: _requests.length,
                    itemBuilder: (context, index) => _buildRequestItem(_requests[index]),
                  ),
                ),
    );
  }

  Widget _buildRequestItem(SupplyRequest request) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () => _showEditDialog(request),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    request.itemName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showEditDialog(request),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Quantity: ${request.quantity} ${request.unit}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPriorityChip(request.priority),
                  const SizedBox(width: 8),
                _buildStatusChip(request.status),
                ],
              ),
              if (request.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Notes: ${request.notes}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                'Requested: ${request.requestedAt.toString().split(' ')[0]}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(int priority) {
    final Map<int, Map<String, dynamic>> priorityData = {
      2: {'color': Colors.red, 'text': 'High'},
      1: {'color': Colors.orange, 'text': 'Medium'},
      0: {'color': Colors.green, 'text': 'Low'},
    };

    final data = priorityData[priority] ?? priorityData[0]!;

    return Chip(
      label: Text(data['text']),
      backgroundColor: data['color'].withOpacity(0.2),
      labelStyle: TextStyle(color: data['color']),
      shape: StadiumBorder(side: BorderSide(color: data['color'])),
    );
  }

  Widget _buildStatusChip(String status) {
  final Map<String, Map<String, dynamic>> statusData = {
    'pending': {'color': Colors.red, 'text': 'Pending'},
    'in progress': {'color': Colors.blue, 'text': 'In Progress'},
    'completed': {'color': Colors.green, 'text': 'Completed'},
  };

  final data = statusData[status.toLowerCase()] ?? statusData['pending']!;

  return Chip(
    label: Text(data['text']),
    backgroundColor: data['color'].withOpacity(0.2),
    labelStyle: TextStyle(color: data['color']),
    shape: StadiumBorder(side: BorderSide(color: data['color'])),
  );
}

 void _showAddRequestDialog() {
  showDialog(
    context: context,
    builder: (context) => SupplyRequestDialog(
      campId: widget.campId,
      onSubmitted: (newRequest) async {
        // Await the _addRequest function before closing the dialog
        await _addRequest(newRequest);
        Navigator.of(context).pop(); // Close the dialog after the update

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request added successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
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
      onSubmitted: (updatedRequest) async {
        // Await the _updateRequest function before closing the dialog
        await _updateRequest(updatedRequest);
        Navigator.of(context).pop(); // Close the dialog after the update

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request updated successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      },
    ),
  );
}

  Future<void> _updateRequest(SupplyRequest request) async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay (remove in production)
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _requests = _requests.map((r) => r.id == request.id ? request : r).toList();
      _isLoading = false;
    });
  }
}