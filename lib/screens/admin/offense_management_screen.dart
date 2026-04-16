// screens/offense_management_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/offense_api_service.dart';
import '../model/offense.dart';

class OffenseManagementScreen extends StatefulWidget {
  const OffenseManagementScreen({Key? key}) : super(key: key);

  @override
  State<OffenseManagementScreen> createState() => _OffenseManagementScreenState();
}

class _OffenseManagementScreenState extends State<OffenseManagementScreen> {
  final OffenseApiService _apiService = OffenseApiService();

  List<Offense> _allOffenses = [];
  List<Offense> _paidOffenses = [];
  List<Offense> _unpaidOffenses = [];

  // Filtered lists
  List<Offense> _filteredAllOffenses = [];
  List<Offense> _filteredPaidOffenses = [];
  List<Offense> _filteredUnpaidOffenses = [];

  String _selectedTab = 'all';
  bool _isLoading = false;
  String? _errorMessage;

  // Date filter variables
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isFilterActive = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _apiService.fetchAllOffenseData();

      setState(() {
        _allOffenses = data['all'] ?? [];
        _paidOffenses = data['paid'] ?? [];
        _unpaidOffenses = data['unpaid'] ?? [];

        // Apply any existing filters
        _applyDateFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // Date filter logic
  void _applyDateFilter() {
    if (_startDate == null && _endDate == null) {
      // No filter - show all
      _filteredAllOffenses = List.from(_allOffenses);
      _filteredPaidOffenses = List.from(_paidOffenses);
      _filteredUnpaidOffenses = List.from(_unpaidOffenses);
      _isFilterActive = false;
    } else {
      // Apply date filter
      _filteredAllOffenses = _allOffenses.where((offense) {
        return _isDateInRange(offense.createdAt);
      }).toList();

      _filteredPaidOffenses = _paidOffenses.where((offense) {
        return _isDateInRange(offense.createdAt);
      }).toList();

      _filteredUnpaidOffenses = _unpaidOffenses.where((offense) {
        return _isDateInRange(offense.createdAt);
      }).toList();

      _isFilterActive = true;
    }
  }

  bool _isDateInRange(DateTime date) {
    // Reset time part for accurate date comparison
    final checkDate = DateTime(date.year, date.month, date.day);

    if (_startDate != null && _endDate != null) {
      final start = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
      final end = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
      return checkDate.isAfter(start.subtract(const Duration(days: 1))) &&
          checkDate.isBefore(end.add(const Duration(days: 1)));
    } else if (_startDate != null) {
      final start = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
      return checkDate.isAfter(start.subtract(const Duration(days: 1)));
    } else if (_endDate != null) {
      final end = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
      return checkDate.isBefore(end.add(const Duration(days: 1)));
    }

    return true;
  }

  List<Offense> _getCurrentOffenses() {
    switch (_selectedTab) {
      case 'paid':
        return _filteredPaidOffenses;
      case 'unpaid':
        return _filteredUnpaidOffenses;
      default:
        return _filteredAllOffenses;
    }
  }

  String _getTitle() {
    final currentList = _getCurrentOffenses();
    String title;

    switch (_selectedTab) {
      case 'paid':
        title = 'Paid Offenses';
        break;
      case 'unpaid':
        title = 'Unpaid Offenses';
        break;
      default:
        title = 'All Offenses';
    }

    return '$title (${currentList.length})';
  }

  Color _getTabColor(String tab) {
    switch (tab) {
      case 'paid':
        return Colors.green;
      case 'unpaid':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  // Show date picker dialog
  Future<void> _showDateFilterDialog() async {
    DateTime? tempStartDate = _startDate;
    DateTime? tempEndDate = _endDate;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter by Date'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Start Date
              ListTile(
                title: const Text('Start Date'),
                subtitle: Text(
                  tempStartDate != null
                      ? DateFormat('dd MMM yyyy').format(tempStartDate!)
                      : 'Not selected',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: tempStartDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setDialogState(() {
                            tempStartDate = date;
                          });
                        }
                      },
                    ),
                    if (tempStartDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          setDialogState(() {
                            tempStartDate = null;
                          });
                        },
                      ),
                  ],
                ),
              ),

              // End Date
              ListTile(
                title: const Text('End Date'),
                subtitle: Text(
                  tempEndDate != null
                      ? DateFormat('dd MMM yyyy').format(tempEndDate!)
                      : 'Not selected',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: tempEndDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setDialogState(() {
                            tempEndDate = date;
                          });
                        }
                      },
                    ),
                    if (tempEndDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          setDialogState(() {
                            tempEndDate = null;
                          });
                        },
                      ),
                  ],
                ),
              ),

              // Quick date filters
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  _buildQuickDateChip('Today', () {
                    final today = DateTime.now();
                    setDialogState(() {
                      tempStartDate = today;
                      tempEndDate = today;
                    });
                  }),
                  _buildQuickDateChip('This Week', () {
                    final now = DateTime.now();
                    setDialogState(() {
                      tempStartDate = now.subtract(Duration(days: now.weekday - 1));
                      tempEndDate = now;
                    });
                  }),
                  _buildQuickDateChip('This Month', () {
                    final now = DateTime.now();
                    setDialogState(() {
                      tempStartDate = DateTime(now.year, now.month, 1);
                      tempEndDate = now;
                    });
                  }),
                  _buildQuickDateChip('Last 7 Days', () {
                    final now = DateTime.now();
                    setDialogState(() {
                      tempStartDate = now.subtract(const Duration(days: 7));
                      tempEndDate = now;
                    });
                  }),
                  _buildQuickDateChip('Last 30 Days', () {
                    final now = DateTime.now();
                    setDialogState(() {
                      tempStartDate = now.subtract(const Duration(days: 30));
                      tempEndDate = now;
                    });
                  }),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _startDate = null;
                  _endDate = null;
                  _applyDateFilter();
                });
                Navigator.pop(context);
              },
              child: const Text('Clear All'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _startDate = tempStartDate;
                  _endDate = tempEndDate;
                  _applyDateFilter();
                });
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDateChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: onTap,
      backgroundColor: Colors.blue.shade50,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Offense Management',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          // Filter button
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _isFilterActive ? Colors.blue : Colors.black,
            ),
            onPressed: _showDateFilterDialog,
            tooltip: 'Filter by date',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter indicator
              if (_isFilterActive)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getFilterText(),
                          style: const TextStyle(fontSize: 13, color: Colors.blue),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _startDate = null;
                            _endDate = null;
                            _applyDateFilter();
                          });
                        },
                        child: const Icon(Icons.close, size: 18, color: Colors.blue),
                      ),
                    ],
                  ),
                ),

              // Tab buttons
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildTabButton('All', 'all')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTabButton('Paid', 'paid')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTabButton('Unpaid', 'unpaid')),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getTitle(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (_isFilterActive)
                    Text(
                      'Filtered',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Content
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  String _getFilterText() {
    if (_startDate != null && _endDate != null) {
      return 'Showing offenses from ${DateFormat('dd MMM yyyy').format(_startDate!)} to ${DateFormat('dd MMM yyyy').format(_endDate!)}';
    } else if (_startDate != null) {
      return 'Showing offenses from ${DateFormat('dd MMM yyyy').format(_startDate!)}';
    } else if (_endDate != null) {
      return 'Showing offenses until ${DateFormat('dd MMM yyyy').format(_endDate!)}';
    }
    return '';
  }

  Widget _buildTabButton(String label, String tab) {
    final isSelected = _selectedTab == tab;
    final color = _getTabColor(tab);

    return ElevatedButton(
      onPressed: () => setState(() => _selectedTab = tab),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final offenses = _getCurrentOffenses();

    if (offenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _isFilterActive ? 'No offenses match the filter' : 'No offenses found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            if (_isFilterActive) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                    _applyDateFilter();
                  });
                },
                child: const Text('Clear filter'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: offenses.length,
      itemBuilder: (context, index) {
        final offense = offenses[index];
        return _buildOffenseCard(offense);
      },
    );
  }

  Widget _buildOffenseCard(Offense offense) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: offense.status == 'paid'
                ? Colors.green.withOpacity(0.3)
                : Colors.red.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.assignment, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'ID: ${offense.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: offense.status == 'paid'
                          ? Colors.green
                          : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      offense.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              _buildCardRow('Driver', offense.driverName),
              _buildCardRow('Officer', offense.officerName),
              _buildCardRow('Thana', offense.thanaName),
              _buildCardRow('Offense Type', offense.offenseType),
              _buildCardRow('Details', offense.detailsOffense),

              Row(
                children: [
                  Expanded(
                    child: _buildCardRow('Fine', '৳${offense.fine}'),
                  ),
                  Expanded(
                    child: _buildCardRow('Point', '${offense.point} pts'),
                  ),
                ],
              ),

              _buildCardRow(
                'Transaction ID',
                offense.transactionId ?? 'N/A',
                valueColor: offense.transactionId == null
                    ? Colors.grey
                    : Colors.black87,
              ),

              _buildCardRow(
                'Date',
                DateFormat('dd MMM yyyy, hh:mm a').format(offense.createdAt),
                icon: Icons.calendar_today,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardRow(String label, String value,
      {Color? valueColor, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                ],
                Text(
                  '$label:',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}