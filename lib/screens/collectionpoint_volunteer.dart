import 'package:flutter/material.dart';
import 'package:resq/utils/auth/auth_service.dart';
import 'package:resq/utils/http/token_http.dart';

class VolunteerScreen extends StatefulWidget {
  const VolunteerScreen({Key? key}) : super(key: key);

  @override
  _VolunteerScreenState createState() => _VolunteerScreenState();
}

class _VolunteerScreenState extends State<VolunteerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _destinationController = TextEditingController();

  List<Map<String, dynamic>> _arrivingItems = [];
  List<Map<String, dynamic>> _dispatchedItems = [];
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _fetchArrivingItems();
    await _fetchMyContributions();
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _fetchArrivingItems() async {
    try {
      final response = await TokenHttp().get(
        '/donation/getArrivedItems?disasterId=${AuthService().getDisasterId()}',
      );

      if (response != null ) {
        setState(() {
          _arrivingItems = List<Map<String, dynamic>>.from(response['incomingItems'] ?? []);
          _dispatchedItems = List<Map<String, dynamic>>.from(response['outgoingItems'] ?? []);
        });
      } else {
        _showSnackBar(response?['message'] ?? 'Failed to fetch items');
      }
    } catch (e) {
      _showSnackBar('Error fetching items: $e');
    }
  }

  Future<void> _fetchMyContributions() async {
    try {
      final response = await TokenHttp().get(
        '/donation/getMyContributions?disasterId=${AuthService().getDisasterId()}',
      );

      if (response != null) {
        setState(() {
          _history = List<Map<String, dynamic>>.from(response['MyContributions'] ?? []);
        });
      } else {
        _showSnackBar(response?['message'] ?? 'Failed to fetch history');
      }
    } catch (e) {
      _showSnackBar('Error fetching history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Point Volunteer'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Incoming', icon: Icon(Icons.arrow_downward)),
            Tab(text: 'Outgoing', icon: Icon(Icons.arrow_upward)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildArrivingItemsTab(),
                _buildDispatchedItemsTab(),
                _buildHistoryTab(),
              ],
            ),
    );
  }

  Widget _buildArrivingItemsTab() {
    if (_arrivingItems.isEmpty) {
      return const Center(child: Text('No arriving items at the moment.'));
    }
    return RefreshIndicator(
      onRefresh: _fetchArrivingItems,
      child: ListView.builder(
        itemCount: _arrivingItems.length,
        itemBuilder: (context, index) {
          final item = _arrivingItems[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(item['donarName'] ?? 'Anonymous Donor'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status: ${item['status'] ?? 'Unknown'}'),
                  if (item['volunteerName'] != null)
                    Text('Handled by: ${item['volunteerName']}'),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showArrivalDetailsDialog(item, index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDispatchedItemsTab() {
    if (_dispatchedItems.isEmpty) {
      return const Center(child: Text('No dispatched items yet.'));
    }
    return RefreshIndicator(
      onRefresh: _fetchArrivingItems,
      child: ListView.builder(
        itemCount: _dispatchedItems.length,
        itemBuilder: (context, index) {
          final item = _dispatchedItems[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(
                item['items'] != null && item['items'].isNotEmpty
                    ? item['items'][0]['name'] ?? 'Unnamed Item'
                    : 'Item',
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status: ${item['status'] ?? 'Unknown'}'),
                  Text('Destination: ${item['campId'] ?? 'Not specified'}'),
                  if (item['volunteerName'] != null)
                    Text('Handled by: ${item['volunteerName']}'),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showDispatchDetailsDialog(item, index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_history.isEmpty) {
      return const Center(child: Text('No history available.'));
    }
    return RefreshIndicator(
      onRefresh: _fetchMyContributions,
      child: ListView.builder(
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final item = _history[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text('${item['action'] ?? 'Activity'}: ${item['item'] ?? 'Item'}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quantity: ${item['quantity'] ?? 'N/A'}'),
                  Text('Destination: ${item['destination'] ?? 'N/A'}'),
                  Text('Time: ${_formatDateTime(item['timestamp'])}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showArrivalDetailsDialog(Map<String, dynamic> item, int index) {
    final canTakeResponsibility = item['volunteerId'] == null;
    final canDispatch = item['status'] == 'arrived' && 
                      item['volunteerId'] == AuthService().getCurrentUserId();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Arrival Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Donor', item['donarName'] ?? 'Anonymous'),
                _buildDetailRow('Status', item['status'] ?? 'Unknown'),
                if (item['volunteerName'] != null)
                  _buildDetailRow('Handled by', item['volunteerName']),
                
                const SizedBox(height: 16),
                const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...(item['donatedItems'] as List<dynamic>).map((donatedItem) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(donatedItem['name'] ?? 'Item', 
                            style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text('Quantity: ${donatedItem['quantity']} ${donatedItem['unit']}'),
                        Text('Category: ${donatedItem['category']}'),
                      ],
                    ),
                  );
                }).toList(),
                
                if (canDispatch) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _destinationController,
                    decoration: const InputDecoration(
                      labelText: 'Destination Camp ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            if (canTakeResponsibility)
              ElevatedButton(
                onPressed: () => _takeResponsibility(item['_id']),
                child: const Text('Take Responsibility'),
              ),
            if (canDispatch)
              ElevatedButton(
                onPressed: () {
                  if (_destinationController.text.isEmpty) {
                    _showSnackBar('Please enter destination camp ID');
                    return;
                  }
                  _dispatchItems(item['_id']);
                  Navigator.pop(context);
                },
                child: const Text('Dispatch Items'),
              ),
          ],
        );
      },
    );
  }

  void _showDispatchDetailsDialog(Map<String, dynamic> item, int index) {
    final canMarkDelivered = item['status'] == 'dispatched' && 
                           item['volunteerId'] == AuthService().getCurrentUserId();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Dispatch Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Status', item['status'] ?? 'Unknown'),
                _buildDetailRow('Destination', item['campId'] ?? 'Not specified'),
                if (item['volunteerName'] != null)
                  _buildDetailRow('Handled by', item['volunteerName']),
                
                const SizedBox(height: 16),
                const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...(item['items'] as List<dynamic>).map((dispatchedItem) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dispatchedItem['name'] ?? 'Item', 
                            style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text('Quantity: ${dispatchedItem['quantity']}'),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            if (canMarkDelivered)
              ElevatedButton(
                onPressed: () => _markAsDelivered(item['_id']),
                child: const Text('Mark as Delivered'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDateTime(dynamic timestamp) {
    if (timestamp == null) return 'Unknown time';
    
    DateTime dateTime;
    if (timestamp is String) {
      dateTime = DateTime.parse(timestamp);
    } else if (timestamp is DateTime) {
      dateTime = timestamp;
    } else {
      return 'Invalid time';
    }
    
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _takeResponsibility(String donationId) async {
    try {
      setState(() => _isLoading = true);
      final response = await TokenHttp().post('/donation/takeResponsibility', {
        'donationId': donationId,
        'disasterId': AuthService().getDisasterId(),
      });

      if (response != null && response['success'] == true) {
        _showSnackBar('Responsibility taken successfully', isError: false);
        await _fetchArrivingItems();
      } else {
        _showSnackBar(response?['message'] ?? 'Failed to take responsibility');
      }
    } catch (e) {
      _showSnackBar('Error taking responsibility: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _dispatchItems(String donationId) async {
    try {
      setState(() => _isLoading = true);
      final response = await TokenHttp().post('/donation/dispatchItems', {
        'donationId': donationId,
        'disasterId': AuthService().getDisasterId(),
        'campId': _destinationController.text,
      });

      if (response != null && response['success'] == true) {
        _showSnackBar('Items dispatched successfully', isError: false);
        _destinationController.clear();
        await _fetchArrivingItems();
      } else {
        _showSnackBar(response?['message'] ?? 'Failed to dispatch items');
      }
    } catch (e) {
      _showSnackBar('Error dispatching items: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsDelivered(String dispatchId) async {
    try {
      setState(() => _isLoading = true);
      final response = await TokenHttp().post('/donation/updateDispatchStatus', {
        'dispatchId': dispatchId,
        'status': 'delivered',
      });

      if (response != null && response['success'] == true) {
        _showSnackBar('Marked as delivered', isError: false);
        await _fetchArrivingItems();
      } else {
        _showSnackBar(response?['message'] ?? 'Failed to update status');
      }
    } catch (e) {
      _showSnackBar('Error updating status: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}