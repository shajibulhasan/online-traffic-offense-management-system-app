import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/auth_service.dart';
import '../../urls/urls.dart';

class OfficerOffenseListScreen extends StatefulWidget {
  @override
  _OfficerOffenseListScreenState createState() => _OfficerOffenseListScreenState();
}

class _OfficerOffenseListScreenState extends State<OfficerOffenseListScreen> {
  String? _selectedSearchType;
  final TextEditingController _searchController = TextEditingController();
  List<Offense> _offenses = [];
  String? _driverName;
  bool _isLoading = false;
  String? _alertMessage;
  Map<String, dynamic>? _driverInfo;

  final List<Map<String, String>> _searchTypes = [
    {'value': 'phone', 'label': 'Phone'},
    {'value': 'email', 'label': 'Email'},
    {'value': 'license', 'label': 'License'},
    {'value': 'nid', 'label': 'NID'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offense List'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            // Search Section
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Search Type Dropdown
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 8),
                      child: DropdownButtonFormField<String>(
                        value: _selectedSearchType,
                        decoration: InputDecoration(
                          labelText: 'Search Type',
                          labelStyle: TextStyle(color: Colors.green, fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text('Select Type', style: TextStyle(fontSize: 14)),
                          ),
                          ..._searchTypes.map((type) {
                            return DropdownMenuItem<String>(
                              value: type['value'],
                              child: Text(type['label']!, style: TextStyle(fontSize: 14)),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedSearchType = value;
                          });
                        },
                      ),
                    ),

                    // Search Value Field
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 8),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Search Value',
                          labelStyle: TextStyle(color: Colors.green, fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          hintText: 'Enter phone, email, license or NID',
                          hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
                    ),

                    // Search Button
                    Container(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _performSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : Text('Search', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),

            // Alert Message
            if (_alertMessage != null)
              Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _alertMessage!,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 18),
                      onPressed: () => setState(() => _alertMessage = null),
                    ),
                  ],
                ),
              ),

            // Driver Info
            if (_driverInfo != null)
              Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Driver Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Divider(),
                    _buildInfoRow('Name:', _driverInfo!['name'] ?? 'N/A'),
                    _buildInfoRow('Email:', _driverInfo!['email'] ?? 'N/A'),
                    _buildInfoRow('Phone:', _driverInfo!['phone'] ?? 'N/A'),
                  ],
                ),
              ),

            // Offenses List
            Expanded(
              child: _buildOffensesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffensesList() {
    // Show empty state
    if (_offenses.isEmpty) {
      String message;
      if (_selectedSearchType == null || _searchController.text.isEmpty) {
        message = 'Please search for a driver.';
      } else if (_driverName == null) {
        message = 'Driver not found.';
      } else {
        message = 'No offenses found for this driver.';
      }

      return Center(
        child: Text(
          message,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // Build list of offenses
    return ListView.builder(
      itemCount: _offenses.length,
      itemBuilder: (context, index) {
        final item = _offenses[index];
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with serial and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Offense #${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.status == 'paid' ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.status == 'paid' ? 'Paid' : 'Unpaid',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(height: 16),

                // Driver and Officer info
                _buildInfoRow('Driver:', item.driverName ?? 'N/A'),
                _buildInfoRow('Officer:', item.officerName ?? 'N/A'),
                _buildInfoRow('Thana:', item.thanaName ?? 'N/A'),
                _buildInfoRow('Details:', item.detailsOffense ?? 'N/A'),

                // Fine and Point
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow('Fine:', '${item.fine ?? 0} TK'),
                    ),
                    Expanded(
                      child: _buildInfoRow('Point:', '${item.point ?? 0}'),
                    ),
                  ],
                ),

                // Transaction ID if paid
                if (item.status == 'paid' && item.transactionId != null)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Text(
                          'Transaction ID: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.transactionId!,
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Action buttons if unpaid
                if (item.status != 'paid')
                  Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/Officer/updateOffense/${item.id}',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 8),
                              textStyle: TextStyle(fontSize: 13),
                            ),
                            child: Text('Edit'),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _deleteOffense(item.id!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 8),
                              textStyle: TextStyle(fontSize: 13),
                            ),
                            child: Text('Delete'),
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
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performSearch() async {
    if (_selectedSearchType == null || _searchController.text.isEmpty) {
      _showAlert('Please select search type and enter value');
      return;
    }

    setState(() {
      _isLoading = true;
      _alertMessage = null;
    });

    try {
      // Get auth token
      String? token = await AuthService.getToken();

      // Build URL with query parameters
      var uri = Uri.parse('${Urls.baseUrl}/officer/offense-list').replace(
          queryParameters: {
            'type': _selectedSearchType!,
            'value': _searchController.text,
          }
      );

      debugPrint('Request URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          if (data['success'] == true) {
            _driverInfo = data['driver'];
            _driverName = data['driver']['name'];

            if (data['data'] != null && data['data'].isNotEmpty) {
              _offenses = (data['data'] as List)
                  .map((item) => Offense.fromJson(item))
                  .toList();
            } else {
              _offenses = [];
              _alertMessage = 'No offenses found for this driver.';
            }
          } else {
            _driverInfo = null;
            _driverName = null;
            _offenses = [];
            _alertMessage = data['message'] ?? 'Driver not found.';
          }
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _driverInfo = null;
          _driverName = null;
          _offenses = [];
          _alertMessage = 'Driver not found with this $_selectedSearchType';
        });
      } else {
        // Try to parse error message from response
        try {
          final errorData = json.decode(response.body);
          _showAlert(errorData['message'] ?? 'Something went wrong!');
        } catch (e) {
          _showAlert('Server error: ${response.statusCode}');
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
      _showAlert('Connection error. Please check your internet connection.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteOffense(int id) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete', style: TextStyle(fontSize: 16)),
        content: Text('Are you sure you want to delete this offense?', style: TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(fontSize: 13)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        String? token = await AuthService.getToken();

        final response = await http.delete(
          Uri.parse('${Urls.baseUrl}/officer/delete-offense/$id'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          _showAlert('Offense deleted successfully');
          _performSearch(); // Refresh the list
        } else {
          _showAlert('Failed to delete offense');
        }
      } catch (e) {
        debugPrint("Delete error: $e");
        _showAlert('Failed to delete offense: Connection error');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAlert(String message) {
    setState(() {
      _alertMessage = message;
    });

    // Auto dismiss after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _alertMessage = null;
        });
      }
    });
  }
}

class Offense {
  final int? id;
  final String? driverName;
  final String? officerName;
  final String? thanaName;
  final String? detailsOffense;
  final int? fine;
  final int? point;
  final String? status;
  final String? transactionId;

  Offense({
    this.id,
    this.driverName,
    this.officerName,
    this.thanaName,
    this.detailsOffense,
    this.fine,
    this.point,
    this.status,
    this.transactionId,
  });

  factory Offense.fromJson(Map<String, dynamic> json) {
    return Offense(
      id: json['id'],
      driverName: json['driver_name'],
      officerName: json['officer_name'],
      thanaName: json['thana_name'],
      detailsOffense: json['details_offense'],
      fine: json['fine'],
      point: json['point'],
      status: json['status'],
      transactionId: json['transaction_id'],
    );
  }
}