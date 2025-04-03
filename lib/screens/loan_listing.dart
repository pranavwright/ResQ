import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resq/utils/http/token_http.dart';

class LoanListingPage extends StatefulWidget {
  const LoanListingPage({super.key});

  @override
  _LoanListingPageState createState() => _LoanListingPageState();
}

class _LoanListingPageState extends State<LoanListingPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _loans = [];
  List<Map<String, dynamic>> _filteredLoans = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String? _selectedStatus;
  String? _selectedLoanType;

  // Status and type filters
  final List<String> _statusOptions = ['All', 'Active', 'Repaid', 'Defaulted', 'Pending'];
  final List<String> _typeOptions = ['All', 'Personal', 'Business', 'Emergency', 'Medical'];

  @override
  void initState() {
    super.initState();
    _fetchLoans();
  }

  Future<void> _fetchLoans() async {
  setState(() {
    _isLoading = true;
    _error = null;
  });

  // Simulate network delay
  await Future.delayed(const Duration(seconds: 1));

  // Mock loan data
  final mockLoans = [
    {
      "loanId": "LN-1001",
      "borrowerName": "John Doe",
      "amount": 5000.00,
      "status": "Active",
      "type": "Personal",
      "issueDate": DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      "dueDate": DateTime.now().add(const Duration(days: 60)).toIso8601String(),
      "repaidAmount": 1500.00
    },
    {
      "loanId": "LN-1002",
      "borrowerName": "Acme Corp",
      "amount": 25000.00,
      "status": "Active",
      "type": "Business",
      "issueDate": DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
      "dueDate": DateTime.now().add(const Duration(days: 90)).toIso8601String(),
      "repaidAmount": 5000.00
    },
    {
      "loanId": "LN-1003",
      "borrowerName": "Sarah Smith",
      "amount": 1000.00,
      "status": "Repaid",
      "type": "Emergency",
      "issueDate": DateTime.now().subtract(const Duration(days: 120)).toIso8601String(),
      "dueDate": DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      "repaidAmount": 1000.00
    },
    {
      "loanId": "LN-1004",
      "borrowerName": "Mike Johnson",
      "amount": 7500.00,
      "status": "Defaulted",
      "type": "Medical",
      "issueDate": DateTime.now().subtract(const Duration(days: 180)).toIso8601String(),
      "dueDate": DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      "repaidAmount": 2500.00
    },
    {
      "loanId": "LN-1005",
      "borrowerName": "Emma Wilson",
      "amount": 3000.00,
      "status": "Pending",
      "type": "Personal",
      "issueDate": DateTime.now().toIso8601String(),
      "dueDate": DateTime.now().add(const Duration(days: 90)).toIso8601String(),
      "repaidAmount": 0.00
    },
  ];

  setState(() {
    _loans = mockLoans;
    _filteredLoans = mockLoans;
    _isLoading = false;
  });
}

  void _filterLoans() {
    setState(() {
      _filteredLoans = _loans.where((loan) {
        final matchesSearch = loan['borrowerName']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
        final matchesStatus = _selectedStatus == null || _selectedStatus == 'All' || loan['status'] == _selectedStatus;
        final matchesType = _selectedLoanType == null || _selectedLoanType == 'All' || loan['type'] == _selectedLoanType;
        return matchesSearch && matchesStatus && matchesType;
      }).toList();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.blue;
      case 'Repaid':
        return Colors.green;
      case 'Defaulted':
        return Colors.red;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLoans,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              labelText: 'Search by borrower',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _searchQuery = '';
                                  _filterLoans();
                                },
                              ),
                            ),
                            onChanged: (value) {
                              _searchQuery = value;
                              _filterLoans();
                            },
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedStatus,
                                  hint: const Text('Filter by status'),
                                  items: _statusOptions.map((status) {
                                    return DropdownMenuItem(
                                      value: status == 'All' ? null : status,
                                      child: Text(status),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedStatus = value;
                                      _filterLoans();
                                    });
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedLoanType,
                                  hint: const Text('Filter by type'),
                                  items: _typeOptions.map((type) {
                                    return DropdownMenuItem(
                                      value: type == 'All' ? null : type,
                                      child: Text(type),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedLoanType = value;
                                      _filterLoans();
                                    });
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _filteredLoans.isEmpty
                          ? const Center(
                              child: Text('No loans found matching your criteria'),
                            )
                          : ListView.builder(
                              itemCount: _filteredLoans.length,
                              itemBuilder: (context, index) {
                                final loan = _filteredLoans[index];
                                return _buildLoanCard(loan);
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildLoanCard(Map<String, dynamic> loan) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loan['borrowerName'] ?? 'Unknown Borrower',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(
                    loan['status'] ?? 'Unknown',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(loan['status'] ?? ''),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Loan ID: ${loan['loanId'] ?? 'N/A'}'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amount: \$${loan['amount']?.toStringAsFixed(2) ?? '0.00'}'),
                      Text('Type: ${loan['type'] ?? 'Unknown'}'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Issued: ${dateFormat.format(DateTime.parse(loan['issueDate'] ?? DateTime.now().toString()))}'),
                      Text('Due: ${dateFormat.format(DateTime.parse(loan['dueDate'] ?? DateTime.now().toString()))}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (loan['status'] == 'Active') ...[
              LinearProgressIndicator(
                value: (loan['repaidAmount'] ?? 0) / (loan['amount'] ?? 1),
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              const SizedBox(height: 4),
              Text(
                'Repaid: \$${loan['repaidAmount']?.toStringAsFixed(2) ?? '0.00'} of \$${loan['amount']?.toStringAsFixed(2) ?? '0.00'}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}