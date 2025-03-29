import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resq/utils/auth/auth_service.dart';
import 'package:resq/utils/http/token_http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:resq/utils/resq_menu.dart';

// Enum for donation status flow
enum DonationStatus { pending, confirmed, arrived, processed, cancelled }

class CollectionPointDashboard extends StatefulWidget {
  const CollectionPointDashboard({Key? key}) : super(key: key);

  @override
  _CollectionPointDashboardState createState() =>
      _CollectionPointDashboardState();
}

class _CollectionPointDashboardState extends State<CollectionPointDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> inventory = [];
  List<Map<String, dynamic>> donationRequests = [];
  List<Map<String, dynamic>> campRequests = [];
  bool isLoadingInventory = true;
  bool isLoadingDonations = true;
  bool isLoadingCampRequests = true;
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInventory();
    _loadDonationRequests();
    _loadCampRequests();
  }

  Future<void> _loadInventory() async {
    setState(() {
      isLoadingInventory = true;
    });

    try {
      var inventoryResponse = await TokenHttp().get(
        '/donation/inventoryItems?disasterId=${AuthService().getDisasterId()}',
      );

      List<Map<String, dynamic>> mappedInventory = [];
      if (inventoryResponse != null && inventoryResponse['list'] is List) {
        mappedInventory =
            (inventoryResponse['list'] as List)
                .map((item) {
                  return {
                    'id': item['_id'] ?? '',
                    'item': item['name'] ?? '',
                    'quantity': item['quantity'] ?? 0,
                    'room': item['room'] ?? '',
                    'unit': item['unit'] ?? '',
                    'category': item['category'] ?? '',
                    'description': item['description'] ?? '',
                    'original': item,
                  };
                })
                .toList()
                .cast<Map<String, dynamic>>();
      }

      setState(() {
        inventory = mappedInventory;
        isLoadingInventory = false;
      });
    } catch (e) {
      setState(() {
        isLoadingInventory = false;
      });
      _showErrorSnackBar('Error loading inventory: $e');
    }
  }

  Future<void> _loadDonationRequests() async {
    setState(() {
      isLoadingDonations = true;
    });

    try {
      var donationResponse = await TokenHttp().get(
        '/donation/generalDonationRequest?disasterId=${AuthService().getDisasterId()}',
      );

      List<Map<String, dynamic>> mappedDonations = [];

      if (donationResponse != null && donationResponse['list'] is List) {
        for (var donation in donationResponse['list']) {
          String formattedDate = '';
          String formattedTime = '';

          if (donation['donationDate'] != null) {
            try {
              final DateTime donatedAt = DateTime.parse(
                donation['donationDate'] ?? donation['donatedAt'].toString(),
              );
              formattedDate = DateFormat('dd-MM-yyyy').format(donatedAt);
              formattedTime = DateFormat('hh:mm a').format(donatedAt);
            } catch (e) {
              formattedDate = 'Unknown';
              formattedTime = 'Unknown';
            }
          }

          List<Map<String, dynamic>> itemDetails = [];
          if (donation['donatedItems'] is List) {
            for (var donatedItem in donation['donatedItems']) {
              itemDetails.add({
                'id': donatedItem['itemId'],
                'quantity': donatedItem['quantity'],
                'room': donatedItem['room'] ?? '',
                'item': donatedItem['name'] ?? 'Unknown',
                'category': donatedItem['category'] ?? 'Not categorized',
                'unit': donatedItem['unit'] ?? '',
                'description': donatedItem['description'] ?? '',
              });
            }
          }

          mappedDonations.add({
            'id': donation['_id'] ?? '',
            'donor': donation['donarName'] ?? 'Unknown',
            'contact_info':
                donation['donarPhone'] ??
                donation['donarEmail'] ??
                'No contact',
            'arriving_date': formattedDate,
            'arriving_time': formattedTime,
            'status': donation['status'] ?? 'pending',
            'items': itemDetails,
            'originalData': donation,
          });
        }
      }

      setState(() {
        donationRequests = mappedDonations;
        isLoadingDonations = false;
      });
    } catch (e) {
      setState(() {
        isLoadingDonations = false;
      });
      _showErrorSnackBar('Error loading donation requests: $e');
    }
  }

Future<void> _loadCampRequests() async {
  setState(() {
    isLoadingCampRequests = true;
    isLoadingDonations = true;
  });

  try {
    // Load donation requests from the API
    var donationRequest = await TokenHttp().get(
      '/donation/campDonationRequest?disasterId=${AuthService().getDisasterId()}',
    );

    List<Map<String, dynamic>> mappedDonations = [];

    if (donationRequest != null && donationRequest['list'] is List) {
      for (var donation in donationRequest['list']) {
        String formattedDate = _formatDate(donation['donationDate'] ?? donation['donatedAt']);

        List<Map<String, dynamic>> itemDetails = [];
        if (donation['donatedItems'] is List) {
          itemDetails = donation['donatedItems'].map<Map<String, dynamic>>((donatedItem) {
            return {
              'id': donatedItem['itemId'] ?? '',
              'quantity': donatedItem['quantity'] ?? 0,
              'room': donatedItem['room'] ?? '',
              'item': donatedItem['name'] ?? 'Unknown',
              'category': donatedItem['category'] ?? 'Not categorized',
              'unit': donatedItem['unit'] ?? '',
              'description': donatedItem['description'] ?? '',
            };
          }).toList();
        }

        mappedDonations.add({
          'id': donation['_id'] ?? '',
          'donor': donation['donarName'] ?? 'Unknown',
          'contact_info': donation['donarPhone'] ?? donation['donarEmail'] ?? 'No contact',
          'arriving_date': formattedDate,
          'arriving_time': '', 
          'status': donation['status'] ?? 'pending',
          'items': itemDetails,
          'originalData': donation,
        });
      }
    }

    setState(() {
      donationRequests = mappedDonations;
      isLoadingDonations = false;
    });
  } catch (e) {
    setState(() {
      isLoadingCampRequests = false;
      isLoadingDonations = false;
    });
    _showErrorSnackBar('Error loading data: $e');
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

  void _showInventoryItemDialog(Map<String, dynamic> item) {
    _roomController.text = item['room'] ?? '';
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Inventory Item - ${item['item']}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ID: ${item['id']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Item: ${item['item']}'),
                  Text('Category: ${item['category'] ?? 'Not categorized'}'),
                  const SizedBox(height: 8),
                  Text('Quantity: ${item['quantity']} ${item['unit'] ?? ''}'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _roomController,
                    decoration: const InputDecoration(
                      labelText: 'Storage Location',
                      hintText: 'e.g., Room A1, Rack 3, Shelf B',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await TokenHttp().post('/donation/updateItemLocation', {
                      'itemId': item['id'],
                      'room': _roomController.text,
                      'disasterId': AuthService().getDisasterId()
                    });

                    setState(() {
                      final index = inventory.indexWhere(
                        (i) => i['id'] == item['id'],
                      );
                      if (index != -1)
                        inventory[index]['room'] = _roomController.text;
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Item location updated successfully'),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update location: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showDonationRequestDialog(Map<String, dynamic> donation) {
    _statusController.text = donation['status'] ?? '';

    // Get the original donation data which contains the donatedItems
    final originalData = donation['originalData'] ?? {};
    final donatedItems = originalData['donatedItems'] ?? [];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Donation Details - ${donation['id']}'),
                const SizedBox(height: 4),
                Text(
                  '${donation['donor']} | ${donation['contact_info']}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Donated on: ${donation['arriving_date']} at ${donation['arriving_time']}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: donation['status'],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items:
                        [
                          'pending',
                          'confirmed',
                          'arrived',
                          'processed',
                          'cancelled',
                        ].map((status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _statusController.text = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Donated Items',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (donatedItems.isEmpty)
                    const Text('No items donated')
                  else
                    ...donatedItems.map<Widget>((item) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Item: ${item['name'] ?? 'Unknown'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('Quantity: ${item['quantity'] ?? 0}'),
                              if (item['description'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Description: ${item['description']}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await TokenHttp()
                        .post('/donation/updateGeneralDonationStatus', {
                          'donationId': donation['id'],
                          'status': _statusController.text,
                        });

                    for (var item in donation['items']) {
                      if (item['room'] != null && item['room'].isNotEmpty) {
                        await TokenHttp().post('/donation/updateItemLocation', {
                          'itemId': item['id'],
                          'room': item['room'],
                        });
                      }
                    }

                    setState(() {
                      final index = donationRequests.indexWhere(
                        (d) => d['id'] == donation['id'],
                      );
                      if (index != -1)
                        donationRequests[index]['status'] =
                            _statusController.text;
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Donation status updated')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating donation: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  Future<void> _handleDonationStatusChange(
    Map<String, dynamic> donation,
  ) async {
    String currentStatus = donation['status'];
    DonationStatus status = DonationStatus.values.firstWhere(
      (e) => e.toString().split('.').last == currentStatus.toLowerCase(),
      orElse: () => DonationStatus.pending,
    );

    switch (status) {
      case DonationStatus.pending:
        // First show the details dialog
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Donation Details - ${donation['id']}'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('ID:', donation['id']),
                      _buildDetailRow('Donor:', donation['donor']),
                      _buildDetailRow(
                        'Contact Info:',
                        donation['contact_info'],
                      ),
                      _buildDetailRow(
                        'Arriving Date:',
                        donation['arriving_date'],
                      ),
                      _buildDetailRow('Status:', donation['status']),
                      const SizedBox(height: 16),
                      const Text(
                        'Donated Items:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (donation['items'] != null &&
                          donation['items'].isNotEmpty)
                        ...donation['items'].map<Widget>((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow('Item ID:', item['id']),
                                _buildDetailRow('Name:', item['item']),
                                _buildDetailRow(
                                  'Quantity:',
                                  item['quantity'].toString(),
                                ),
                                _buildDetailRow('Category:', item['category']),
                                _buildDetailRow('Unit:', item['unit']),
                                if (item['description']?.isNotEmpty ?? false)
                                  _buildDetailRow(
                                    'Description:',
                                    item['description'],
                                  ),
                                const Divider(),
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
                ],
              ),
        );

        // Then show the status change dialog
        DateTime? initialDate;
        if (donation['arriving_date'] != null &&
            donation['arriving_date'] != 'Unknown') {
          try {
            final parts = donation['arriving_date'].split('-');
            if (parts.length == 3) {
              initialDate = DateTime(
                int.parse(parts[2]),
                int.parse(parts[1]),
                int.parse(parts[0]),
              );
            }
          } catch (e) {
            print('Error parsing date: $e');
          }
        }

        final pendingResult = await showDialog<DonationStatus>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Donation Status'),
                content: const Text(
                  'Would you like to confirm or cancel this donation?',
                ),
                actions: [
                  TextButton(
                    onPressed:
                        () => Navigator.pop(context, DonationStatus.cancelled),
                    child: const Text('Cancel Donation'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: initialDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        Navigator.pop(context, DonationStatus.confirmed);
                        final day = date.day.toString().padLeft(2, '0');
                        final month = date.month.toString().padLeft(2, '0');
                        final year = date.year.toString();
                        donation['arriving_date'] = '$day-$month-$year';
                      }
                    },
                    child: const Text('Confirm Donation'),
                  ),
                ],
              ),
        );
        if (pendingResult != null) {
          setState(() {
            donation['status'] = pendingResult.toString().split('.').last;
          });
          await _updateDonationStatus(
            donation['id'],
            donation['status'],
            donation['arriving_date'],
          );
        }
        break;

      case DonationStatus.confirmed:
        final confirmedResult = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Donation Status'),
                content: const Text(
                  'Has the donation arrived at the collection point?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Not Yet'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Mark as Arrived'),
                  ),
                ],
              ),
        );
        if (confirmedResult == true) {
          setState(() {
            donation['status'] =
                DonationStatus.arrived.toString().split('.').last;
          });
          await _updateDonationStatus(
            donation['id'],
            donation['status'],
            donation['arriving_date'],
          );
        }
        break;

      case DonationStatus.arrived:
        final arrivedResult = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Donation Status'),
                content: const Text(
                  'Has the donation been processed and distributed?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Still Processing'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Mark as Processed'),
                  ),
                ],
              ),
        );
        if (arrivedResult == true) {
          setState(() {
            donation['status'] =
                DonationStatus.processed.toString().split('.').last;
          });
          await _updateDonationStatus(
            donation['id'],
            donation['status'],
            donation['arriving_date'],
          );
        }
        break;

      case DonationStatus.cancelled:
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Donation Cancelled'),
                content: const Text(
                  'This donation has been cancelled and cannot be changed.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
        break;

      case DonationStatus.processed:
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Donation Processed'),
                content: const Text(
                  'This donation has been successfully processed and distributed.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
        break;
    }
  }

  // Helper widget to build consistent detail rows
  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? 'Not available',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateDonationStatus(
    String donationId,
    String status,
    String date,
  ) async {
    try {
      List<String> parts = date.split('-');
      if (parts.length == 3) {
        String year = parts[2];
        String month = parts[1];
        String day = parts[0];
        String isoDateString = '$year-$month-$day';
        await TokenHttp().post('/donation/updateDonation', {
          'donationId': donationId,
          'disasterId': AuthService().getDisasterId(),
          'status': status,
          'donationDate': DateTime.parse(isoDateString).toIso8601String(),
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to update donation status: $e');
    }
  }

  bool isEmail(String contact) {
    return contact.contains('@') && contact.contains('.');
  }

  void _handleContactPress(String contact) {
    if (isEmail(contact)) {
      launchUrl(Uri.parse('mailto:$contact'));
    } else {
      launchUrl(Uri.parse('tel:$contact'));
    }
  }

  void _showCampRequestDialog(Map<String, dynamic> campRequest) {
    _dateController.text = campRequest['pickup_date'] ?? '';
    _timeController.text = campRequest['pickup_time'] ?? '';
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(campRequest['camp']),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Contact: ${campRequest['camp_contact']}'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Pickup Date',
                      hintText: 'DD-MM-YYYY',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        final day = picked.day.toString().padLeft(2, '0');
                        final month = picked.month.toString().padLeft(2, '0');
                        final year = picked.year.toString();
                        _dateController.text = '$day-$month-$year';
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _timeController,
                    decoration: const InputDecoration(
                      labelText: 'Pickup Time',
                      hintText: 'HH:MM AM/PM',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    readOnly: true,
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        final hour =
                            picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
                        final minute = picked.minute.toString().padLeft(2, '0');
                        final period =
                            picked.period == DayPeriod.am ? 'AM' : 'PM';
                        _timeController.text = '$hour:$minute $period';
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: campRequest['status'],
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        ['Pending', 'Scheduled', 'Completed', 'Canceled'].map((
                          status,
                        ) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          campRequest['status'] = value;
                        });
                      }
                    },
                  ),
                  const Divider(height: 24),
                  const Text(
                    'Requested Items:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(campRequest['items'].length, (index) {
                    final item = campRequest['items'][index];
                    final itemController = TextEditingController(
                      text: item['quantity'].toString(),
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Item: ${item['item']}'),
                          const SizedBox(height: 4),
                          Text('ID: ${item['id']}'),
                          const SizedBox(height: 4),
                          Text(
                            'Room: ${item['room']}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Quantity: '),
                              Expanded(
                                child: TextField(
                                  controller: itemController,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      campRequest['items'][index]['quantity'] =
                                          int.tryParse(value) ?? 0;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    final index = campRequests.indexWhere(
                      (c) => c['id'] == campRequest['id'],
                    );
                    if (index != -1) {
                      campRequests[index]['pickup_date'] = _dateController.text;
                      campRequests[index]['pickup_time'] = _timeController.text;
                    }
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Camp request updated')),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  Widget _buildInventoryTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Current Inventory',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    onPressed: _loadInventory,
                  ),
                ],
              ),
            ),
            const Divider(),
            if (isLoadingInventory)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (inventory.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No inventory found'),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Item')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('Location')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows:
                      inventory.map((item) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(item['id'].toString().substring(0, 8)),
                            ),
                            DataCell(Text(item['item'])),
                            DataCell(Text(item['category'] ?? '')),
                            DataCell(
                              Text('${item['quantity']} ${item['unit'] ?? ''}'),
                            ),
                            DataCell(Text(item['room'] ?? 'Not assigned')),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showInventoryItemDialog(item),
                                tooltip: 'Edit Room',
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationRequestsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Donation Requests',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    onPressed: _loadDonationRequests,
                  ),
                ],
              ),
            ),
            const Divider(),
            if (isLoadingDonations)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (donationRequests.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No donation requests found'),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Donor')),
                    DataColumn(label: Text('Contact Info')),
                    DataColumn(label: Text('Arriving Date')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows:
                      donationRequests.map((donation) {
                        return DataRow(
                          onSelectChanged:
                              (_) => _handleDonationStatusChange(donation),
                          cells: [
                            DataCell(Text(donation['id'])),
                            DataCell(Text(donation['donor'])),
                            DataCell(
                              InkWell(
                                onTap:
                                    () => _handleContactPress(
                                      donation['contact_info'],
                                    ),
                                child: Text(
                                  donation['contact_info'],
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Text('${donation['arriving_date']}')),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(donation['status']),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  donation['status'],
                                  style: TextStyle(
                                    color: _getStatusTextColor(
                                      donation['status'],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCampRequestsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Camp Requests',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    onPressed: _loadCampRequests,
                  ),
                ],
              ),
            ),
            const Divider(),
            if (isLoadingCampRequests)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (campRequests.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No camp requests found'),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Camp')),
                    DataColumn(label: Text('Pickup Date/Time')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Items')),
                  ],
                  rows:
                      campRequests.map((request) {
                        return DataRow(
                          onSelectChanged:
                              (_) => _showCampRequestDialog(request),
                          cells: [
                            DataCell(Text(request['id'])),
                            DataCell(Text(request['camp'])),
                            DataCell(
                              Text(
                                '${request['pickup_date']}\n${request['pickup_time']}',
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      request['status'] == 'Scheduled'
                                          ? Colors.green.shade100
                                          : Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  request['status'],
                                  style: TextStyle(
                                    color:
                                        request['status'] == 'Scheduled'
                                            ? Colors.green.shade800
                                            : Colors.orange.shade800,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Text('${request['items'].length} items')),
                          ],
                        );
                      }).toList(),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processed':
        return Colors.purple.shade100;
      case 'arrived':
        return Colors.green.shade100;
      case 'confirmed':
        return Colors.blue.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      default:
        return Colors.orange.shade100; // pending
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'processed':
        return Colors.purple.shade800;
      case 'arrived':
        return Colors.green.shade800;
      case 'confirmed':
        return Colors.blue.shade800;
      case 'cancelled':
        return Colors.red.shade800;
      default:
        return Colors.orange.shade800; // pending
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Point Dashboard'),
        backgroundColor: Colors.blueGrey[800],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          tabs: const [
            Tab(text: 'Inventory'),
            Tab(text: 'Donation Requests'),
            Tab(text: 'Camp Requests'),
          ],
        ),
      ),
      drawer:
          MediaQuery.of(context).size.width < 800
              ? const ResQMenu(roles: ['admin'])
              : null,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              if (MediaQuery.of(context).size.width >= 800)
                const ResQMenu(roles: ['admin'], showDrawer: false),
              const Divider(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    SingleChildScrollView(child: _buildInventoryTab()),
                    SingleChildScrollView(child: _buildDonationRequestsTab()),
                    SingleChildScrollView(child: _buildCampRequestsTab()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _roomController.dispose();
    _quantityController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _statusController.dispose();
    super.dispose();
  }
}
