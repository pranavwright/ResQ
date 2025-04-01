import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:resq/utils/auth/auth_service.dart';
import 'package:resq/utils/http/token_http.dart';
import 'package:resq/utils/http/token_less_http.dart';

// Enum for request status
enum RequestStatus { pending, approved, rejected, fulfilled }

class CampSupplyRequestScreen extends StatefulWidget {
  final String campId;
  final String campName;

  const CampSupplyRequestScreen({
    Key? key,
    required this.campId,
    required this.campName,
  }) : super(key: key);

  @override
  _CampSupplyRequestScreenState createState() =>
      _CampSupplyRequestScreenState();
}

class _CampSupplyRequestScreenState extends State<CampSupplyRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _notesController = TextEditingController();
  int _selectedPriority = 1;
  List<Map<String, dynamic>> _supplyRequests = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> _itemsList = [];
  String? _error;
  bool _loadingItems = false;
  bool _showNewRequestForm = false;
  // Define item categories
  final Map<String, List<Map<String, dynamic>>> _itemCategories = {
    'Food': [],
    'Water': [],
    'Shelter': [],
    'Medical': [],
    'Hygiene': [],
    'Other': [],
  };

  // Use a list to store selected items with quantity and availability
  final List<Map<String, dynamic>> _selectedItems = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime _selectedDate = DateTime.now();
  // Map to store item availability status
  final Map<String, dynamic> _itemAvailability = {};
  
  bool _isLoadingAvail = false;

  @override
  void initState() {
    super.initState();
    _loadSupplyRequests();
    _fetchItems();
  }

  Future<void> _loadSupplyRequests() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await TokenHttp().get(
        '/donation/campDonationRequest?campId=${widget.campId}&disasterId=${AuthService().getDisasterId()}',
      );

      if (response != null && response['requests'] is List) {
        _supplyRequests = List<Map<String, dynamic>>.from(response['requests']);
      } else {
        _supplyRequests = [];
      }
    } catch (e) {
      _showErrorSnackBar('Error loading supply requests: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchItems() async {
    setState(() => _loadingItems = true);
    try {
      final response = await TokenLessHttp().get(
        '/donation/items?disasterId=${AuthService().getDisasterId()}',
      );

      if (response is Map && response.containsKey('list') && response['list'] is List) {
        _itemsList = List<Map<String, dynamic>>.from(response['list']);
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      _error = 'Error fetching items: $e';
    } finally {
      setState(() => _loadingItems = false);
    }
  }

  //method to check item availabilty
  Future<void> _checkItemAvailability(String itemId, int quantity) async {
    try {
      final disasterId = AuthService().getDisasterId();
      setState(() {
        _isLoadingAvail=true;
      });

      final response = await TokenHttp().get(
        '/donation/getIndividualAvailableItems?disasterId=$disasterId&item={"_id":"$itemId","quantity":$quantity}',
      );

      if (response != null) {
        // Store availability info by itemId, not name
        if (response['message'] == "in stock") {
          setState(() {
            _itemAvailability[itemId] = {
              'status': 'in stock',
              'availableQuantity':
                  response['totalAvailableAfterDonations'] ?? 0,
              'availableInCurrentCamp': response['availableInCurrentCamp'] ?? 0,
              'reservedInOtherCamps': response['reservedInOtherCamps'] ?? 0,
              'currentlyAvailable': response['currentlyAvailable'] ?? 0,
              'requestAvailableAfterDays': 0,
              'fullRequestAvailable': true,
              'otherCampReservations': response['otherCampReservations'] ?? [],
            };
          });
        } else if (response['message'] == "out of stock") {
          List<dynamic> availableSoon = response['availableSoon'] ?? [];
          int totalAvailableAfterDonations =
              response['totalAvailableAfterDonations'] ?? 0;
          bool fullRequestAvailable = response['fullRequestAvailable'] ?? false;
          int requestAvailableAfterDays =
              response['requestAvailableAfterDays'] ?? 0;

          setState(() {
            _itemAvailability[itemId] = {
              'status': 'out of stock',
              'availableQuantity': response['currentlyAvailable'] ?? 0,
              'availableInCurrentCamp': response['availableInCurrentCamp'] ?? 0,
              'reservedInOtherCamps': response['reservedInOtherCamps'] ?? 0,
              'currentlyAvailable': response['currentlyAvailable'] ?? 0,
              'availableSoon':
                  availableSoon.map((entry) {
                    final donation = entry['donation'];
                    return {
                      'donationId': donation['_id'],
                      'status': donation['status'],
                      'quantity': entry['quantity'],
                      'confirmDate': donation['confirmDate'],
                      'daysUntilAvailable': entry['daysUntilAvailable'] ?? 0,
                    };
                  }).toList(),
              'totalAvailableAfterDonations': totalAvailableAfterDonations,
              'fullRequestAvailable': fullRequestAvailable,
              'requestAvailableAfterDays': requestAvailableAfterDays,
              'otherCampReservations': response['otherCampReservations'] ?? [],
            };
          });
        } else {
          setState(() {
            _itemAvailability[itemId] = {
              'status': 'error',
              'message': 'Unexpected response: ${response['message']}',
            };
          });
        }
      } else {
        setState(() {
          _itemAvailability[itemId] = {
            'status': 'error',
            'message': 'Failed to check availability',
          };
        });
      }
    } catch (e) {
      print("Error checking availability: $e");
      setState(() {
        _itemAvailability[itemId] = {'status': 'error', 'message': 'Error: $e'};
      });
    }finally {
      setState(() {
        _isLoadingAvail = false;
      });
    }
  }

  String _formatDate(dynamic date) {
    if (date != null) {
      try {
        final DateTime dateTime = DateTime.parse(date.toString());
        return DateFormat('dd-MM-yyyy').format(dateTime);
      } catch (e) {
        return 'Unknown';
      }
    }
    return 'Unknown';
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addSupplyRequest() async {
    if (_formKey.currentState!.validate()) {
      final newNotes = _notesController.text;

      if (_selectedItems.isEmpty) {
        _showErrorSnackBar('Please select at least one item.');
        return;
      }

      // Check if all selected items are available in requested quantity
      bool canFulfillRequest = true;
      String unavailableItemName = '';

      for (var item in _selectedItems) {
        final itemId = item['_id']; 
        final itemName = item['name'];
        final availability = _itemAvailability[itemId];

        if (availability == null) {
          canFulfillRequest = false;
          unavailableItemName = itemName;
          break;
        }

        if (availability['fullRequestAvailable'] == false) {
          canFulfillRequest = false;
          unavailableItemName = itemName;
          break;
        }
      }

      if (!canFulfillRequest) {
        _showErrorSnackBar(
          'Cannot fulfill request for $unavailableItemName. Insufficient quantity available.',
        );
        return;
      }

      try {
        // Prepare the items list for the request, using the IDs directly
        List<Map<String, dynamic>> itemsForRequest =
            _selectedItems.map((item) {
              return {
                'quantity': item['quantity'],
                'itemId': item['_id'], // Use the stored ID directly
              };
            }).toList();

        print('Sending request with items: $itemsForRequest'); // Debug log

        final response = await TokenHttp()
            .post('/donation/campDonationRequest', {
              'disasterId': AuthService().getDisasterId(),
              'campId': widget.campId ?? AuthService().assignPlace,
              'items': itemsForRequest,
              'notes': newNotes,
              'priority': _selectedPriority,
              'pickUpDate': _selectedDate.toIso8601String(),
            });

        if (response != null && response['success'] == true) {
          _showSuccessSnackBar('Supply request added successfully');
          _loadSupplyRequests();
          _clearInputFields();
          setState(() {
            _showNewRequestForm = false;
          });
        } else {
          _showErrorSnackBar(
            'Failed to add supply request. ${response['message'] ?? 'Unknown error'}',
          );
        }
      } catch (e) {
        _showErrorSnackBar('Error adding supply request: $e');
      }
    }
  }

  void _clearInputFields() {
    _notesController.clear();
    setState(() {
      _selectedItems.clear();
      _selectedPriority = 1;
      _searchQuery = '';
      _searchController.clear();
      _selectedDate = DateTime.now();
    });
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'fulfilled':
        return 'Fulfilled';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.amber;
      case 'approved':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      case 'fulfilled':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Supply Requests for ${widget.campName}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSupplyRequestList(),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showNewRequestForm = !_showNewRequestForm;
                          });
                        },
                        child: Text(
                          _showNewRequestForm
                              ? 'Hide Request Form'
                              : 'New Request',
                        ),
                      ),
                      if (_showNewRequestForm) ...[
                        Form(
                          key: _formKey,
                          child: _buildAddSupplyRequestForm(),
                        ),
                        if (_loadingItems)
                          const Center(child: CircularProgressIndicator())
                        else if (_error != null)
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                      ],
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildSupplyRequestList() {
    if (_supplyRequests.isEmpty) {
      return const Center(
        child: Text('No supply requests have been made for this camp.'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Existing Supply Requests:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _supplyRequests.length,
          itemBuilder: (context, index) {
            final request = _supplyRequests[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request ID: ${request['id']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Requested On: ${request['requested_date']}'),
                    Text('Pick Up On: ${request['pickup_date']}'),
                    Text(
                      'Status: ${_getStatusText(request['status'])}',
                      style: TextStyle(
                        color: _getStatusColor(request['status']),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAddSupplyRequestForm() {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add New Supply Request',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildSearchField(),
            const SizedBox(height: 12),
            _buildItemList(),
            const SizedBox(height: 12),
            _buildDatePicker(),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Additional details (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items:
                  <int>[0, 1, 2].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(
                        value == 0
                            ? 'Low'
                            : value == 1
                            ? 'Medium'
                            : 'High',
                      ),
                    );
                  }).toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedPriority = newValue;
                  });
                }
              },
              validator:
                  (value) => value == null ? 'Please select priority' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: !_isLoadingAvail ?? _checkIfAllItemsAvailable() ? _addSupplyRequest : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    !_isLoadingAvail ??_checkIfAllItemsAvailable() ? null : Colors.grey,
              ),
              child: const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }

  bool _checkIfAllItemsAvailable() {
    if (_selectedItems.isEmpty) return false;

    for (var item in _selectedItems) {
      final itemId = item['_id']; // Use ID for lookup
      final availability = _itemAvailability[itemId];
      if (availability == null ||
          availability['fullRequestAvailable'] == false) {
        return false;
      }
    }

    return true;
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: const InputDecoration(
        labelText: 'Search Items',
        hintText: 'Search for items by name',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.search),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      },
    );
  }

  Widget _buildItemList() {
    // Filter items based on the search query
    List<Map<String, dynamic>> filteredItems = [];

    _itemCategories.forEach((category, items) {
      for (var item in items) {
        if (item['name']!.toLowerCase().contains(_searchQuery)) {
          filteredItems.add({
            'category': category,
            'name': item['name'],
            'unit': item['unit'],
            '_id': item['_id'],
          });
        }
      }
    });

    if (filteredItems.isEmpty && _searchQuery.isNotEmpty) {
      return const Text('No items found matching your search.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Items and Quantity:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        if (filteredItems.isNotEmpty)
          ...filteredItems.map((item) {
            final itemName = item['name']!;
            final itemUnit = item['unit']!;
            final itemId = item['_id'] ?? '';
            final int index = _selectedItems.indexWhere((element) => element['_id'] == itemId);
            final bool itemExists = index >= 0;
            int quantity = itemExists ? _selectedItems[index]['quantity'] : 0;
            final availability = _itemAvailability[itemId];
            final availabilityStatus = availability?['status'] ?? 'checking';
            final currentlyAvailable = availability?['currentlyAvailable'] ?? 0;
            final totalAvailable =
                availability?['totalAvailableAfterDonations'] ?? 0;
            final bool canFulfillRequest =
                availability?['fullRequestAvailable'] ?? false;

            return StatefulBuilder(
              builder: (context, setState) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$itemName ($itemUnit)',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _isLoadingAvail
                                        ? 'Checking availability...'
                                        :
                                    availabilityStatus == 'in stock'
                                        ? 'Available: $currentlyAvailable $itemUnit'
                                        : availabilityStatus == 'out of stock'
                                        ? 'Current stock: $currentlyAvailable $itemUnit (Total after donations: $totalAvailable $itemUnit)'
                                        : 'Checking availability...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          availabilityStatus == 'in stock'
                                              ? Colors.green
                                              : availabilityStatus ==
                                                  'out of stock'
                                              ? Colors.orange
                                              : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () async {
                                    if (quantity > 0) {
                                      setState(() {
                                        quantity--;
                                        if (itemExists) {
                                          _selectedItems[index]['quantity'] = quantity;
                                        } else {
                                          _selectedItems.add({
                                            'name': itemName,
                                            'quantity': quantity,
                                            'unit': itemUnit,
                                            '_id': itemId,
                                          });
                                        }
                                      });
                                      await _checkItemAvailability(
                                        itemId,
                                        quantity,
                                      );
                                    }
                                    if (quantity == 0) {
                                      setState(() {
                                        _selectedItems.removeWhere(
                                           (e) => e['_id'] == itemId,
                                        );
                                      });
                                    }
                                  },
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        quantity > 0
                                            ? Colors.blue.shade100
                                            : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$quantity',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () async {
                                  setState(() {
                                    quantity++;
                                    if (itemExists) {
                                      _selectedItems[index]['quantity'] = quantity;
                                    } else {
                                      _selectedItems.add({
                                        'name': itemName,
                                        'quantity': quantity,
                                        'unit': itemUnit,
                                        '_id':
                                          itemId, // Store the ID in selected items
                                      });
                                    }
                                  });
                                  await _checkItemAvailability(
                                    itemId,
                                    quantity,
                                  ); // Use ID directly
                                  },
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 60,
                                  child: TextFormField(
                                  initialValue: quantity.toString(),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) async {
                                    if(value.isEmpty) {
                                      setState(() {
                                        quantity = 0;
                                      });
                                      return;
                                    }
                                    final newQuantity = int.tryParse(value) ?? 0;
                                    setState(() {
                                    quantity = newQuantity;
                                    if (newQuantity > 0) {
                                      if (itemExists) {
                                        _selectedItems[index]['quantity'] = newQuantity;
                                      } else {
                                        _selectedItems.add({
                                          'name': itemName,
                                          'quantity': newQuantity,
                                          'unit': itemUnit,
                                          '_id': itemId,
                                        });
                                      }
                                    } else if (newQuantity == 0) {
                                      _selectedItems.removeWhere(
                                      (e) => e['_id'] == itemId,
                                      );
                                    }
                                    });
                                    await _checkItemAvailability(
                                    itemId,
                                    newQuantity,
                                    );
                                  },
                                  ),
                                ),
                                  
                              ],
                            ),
                          ],
                        ),
                        if (quantity > 0 && !canFulfillRequest)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.red.shade700,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Insufficient quantity available for this request',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (availabilityStatus == 'out of stock' &&
                            availability != null &&
                            availability['availableSoon'] != null &&
                            availability['availableSoon'].isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Expected restocking:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ...List.generate(
                                  availability['availableSoon'].length > 2
                                      ? 2
                                      : availability['availableSoon'].length,
                                  (index) {
                                    final donation =
                                        availability['availableSoon'][index];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8.0,
                                        bottom: 2.0,
                                      ),
                                      child: Text(
                                        '• ${donation['quantity']} $itemUnit on ${_formatDate(donation['confirmDate'])}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (availability['availableSoon'].length > 2)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      '• ... and ${availability['availableSoon'].length - 2} more restocks',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        if (availability != null &&
                            availability['reservedInOtherCamps'] > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.business,
                                  size: 12,
                                  color: Colors.orange.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${availability['reservedInOtherCamps']} $itemUnit reserved by other camps',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList()
        else if (_searchQuery.isEmpty)
          const Text('Start typing to search for items.'),
      ],
    );
  }

  Widget _buildDatePicker() {
    // Determine earliest date when all items will be available
    DateTime earliestAvailableDate = DateTime.now();
    bool hasUnavailableItems = false;
    Map<String, DateTime?> itemAvailabilityDates = {};

    if (_selectedItems.isNotEmpty) {
      for (var item in _selectedItems) {
        final itemName = item['name'];
        final itemId = item['_id'];
        final availability = _itemAvailability[itemId];

        if (availability != null && availability['status'] == 'out of stock') {
          hasUnavailableItems = true;

          // Check if item will be available in the future
          if (availability['fullRequestAvailable'] == true) {
            // Item will be fully available after some days
            final daysUntilAvailable =
                availability['requestAvailableAfterDays'] ?? 0;
            final availableDate = DateTime.now().add(
              Duration(days: daysUntilAvailable),
            );
            itemAvailabilityDates[itemName] = availableDate;

            // Update earliest date if this item becomes available later
            if (availableDate.isAfter(earliestAvailableDate)) {
              earliestAvailableDate = availableDate;
            }
          } else {
            // Item won't be fully available in known timeframe
            itemAvailabilityDates[itemName] = null;
          }
        }
      }
    }

    // If we have unavailable items that will never be fully available, disable date picker
    bool isDatePickerDisabled =
        hasUnavailableItems && itemAvailabilityDates.containsValue(null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Pickup Date:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed:
              isDatePickerDisabled
                  ? null
                  : () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: earliestAvailableDate,
                      firstDate:
                          earliestAvailableDate, // Use earliest available date
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      helpText:
                          hasUnavailableItems
                              ? 'Select date on or after ${DateFormat('dd-MM-yyyy').format(earliestAvailableDate)}'
                              : 'Select pickup date',
                      cancelText: 'Cancel',
                      confirmText: 'Confirm Date',
                    );
                    if (pickedDate != null && pickedDate != _selectedDate) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    }
                  },
          style: ElevatedButton.styleFrom(
            backgroundColor: hasUnavailableItems ? Colors.amber : null,
          ),
          child: Text(
            isDatePickerDisabled
                ? 'Date Picker Disabled'
                : hasUnavailableItems
                ? 'Pick a date (Earliest: ${DateFormat('dd-MM-yyyy').format(earliestAvailableDate)})'
                : 'Pick a date',
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Selected Date: ${DateFormat('dd-MM-yyyy').format(_selectedDate)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDatePickerDisabled ? Colors.grey : Colors.black,
          ),
        ),

        // Show availability information
        if (hasUnavailableItems) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isDatePickerDisabled
                      ? Colors.red.shade50
                      : Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    isDatePickerDisabled
                        ? Colors.red.shade200
                        : Colors.amber.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isDatePickerDisabled
                          ? Icons.error_outline
                          : Icons.info_outline,
                      color:
                          isDatePickerDisabled
                              ? Colors.red
                              : Colors.amber.shade800,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isDatePickerDisabled
                            ? 'Some items are not available in sufficient quantity'
                            : 'Some items will be available later',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              isDatePickerDisabled
                                  ? Colors.red
                                  : Colors.amber.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (var item in _selectedItems)
                  if (_itemAvailability[item['_id']]?['status'] ==
                      'out of stock')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: _buildItemAvailabilityInfo(
                        item['name'],
                        item['unit'],
                        item['_id'],
                      ),
                    ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildItemAvailabilityInfo(String itemName, String unit, String itemId) {
    final availability = _itemAvailability[itemId];
    if (availability == null) return const SizedBox();

    final currentlyAvailable = availability['currentlyAvailable'] ?? 0;
    final totalAvailable = availability['totalAvailableAfterDonations'] ?? 0;
    final fullRequestAvailable = availability['fullRequestAvailable'] ?? false;

    if (!fullRequestAvailable) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• $itemName: Only $currentlyAvailable of $totalAvailable $unit available',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              'Request cannot be fulfilled with available donations',
              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
            ),
          ),
        ],
      );
    }

    final requestAvailableAfterDays =
        availability['requestAvailableAfterDays'] ?? 0;
    final availableDate = DateTime.now().add(
      Duration(days: requestAvailableAfterDays),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• $itemName: Currently $currentlyAvailable $unit available',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        if (requestAvailableAfterDays > 0)
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              'Full quantity will be available on ${DateFormat('dd-MM-yyyy').format(availableDate)}',
              style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
            ),
          ),
        if (requestAvailableAfterDays == 0 &&
            availability['availableSoon'] != null)
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              'Additional stock arriving today',
              style: TextStyle(color: Colors.green.shade700, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
