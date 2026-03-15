import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/auth_service.dart';
import '../../urls/urls.dart';

class EditOffenseScreen extends StatefulWidget {
  final String token;
  final int offenseId;

  const EditOffenseScreen({
    super.key,
    required this.token,
    required this.offenseId,
  });

  @override
  State<EditOffenseScreen> createState() => _EditOffenseScreenState();
}

class _EditOffenseScreenState extends State<EditOffenseScreen> {
  // Controllers
  late TextEditingController _offenseDetailsController;
  late TextEditingController _fineController;
  late TextEditingController _pointController;

  // Variables
  String _selectedOffenseType = '';
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;
  int? _driverId;
  String? _driverName;
  String? _officerName;
  String? _thanaName;

  // Offense types with fine and point
  final Map<String, Map<String, int>> _offenseData = {
    "Speeding": {"fine": 500, "point": 5},
    "Illegal Parking": {"fine": 400, "point": 4},
    "Running Red Light": {"fine": 300, "point": 3},
    "Reckless Driving": {"fine": 500, "point": 5},
    "Driving Under Influence": {"fine": 400, "point": 4},
    "Using Mobile While Driving": {"fine": 600, "point": 6},
    "Not Wearing Seatbelt": {"fine": 500, "point": 5},
    "Overloading": {"fine": 400, "point": 4},
    "Without License": {"fine": 700, "point": 7},
    "License Expired": {"fine": 300, "point": 3},
    "Without Helmet": {"fine": 400, "point": 4},
    "Other": {"fine": 500, "point": 5},
  };

  @override
  void initState() {
    super.initState();
    _offenseDetailsController = TextEditingController();
    _fineController = TextEditingController();
    _pointController = TextEditingController();
    _loadOffenseData();
  }

  @override
  void dispose() {
    _offenseDetailsController.dispose();
    _fineController.dispose();
    _pointController.dispose();
    super.dispose();
  }

  // Load offense data for editing
  Future<void> _loadOffenseData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('${Urls.baseUrl}/officer/edit-offense/${widget.offenseId}'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Load offense response: ${response.statusCode}');
      debugPrint('Load offense body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          final offenseData = data['data'];

          setState(() {
            _selectedOffenseType = offenseData['offense_type'] ?? '';
            _offenseDetailsController.text = offenseData['details_offense'] ?? '';
            _fineController.text = offenseData['fine']?.toString() ?? '0';
            _pointController.text = offenseData['point']?.toString() ?? '0';
            _driverId = offenseData['driver_id'];
            _driverName = offenseData['driver_name'];
            _officerName = offenseData['officer_name'];
            _thanaName = offenseData['thana_name'];
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Failed to load offense data';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Error loading offense data. Status: ${response.statusCode}';
        });
      }
    } catch (e) {
      debugPrint("Load error: $e");
      setState(() {
        _errorMessage = 'Connection error. Please check your internet connection.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Update offense
  Future<void> _updateOffense() async {
    // Validation
    if (_selectedOffenseType.isEmpty) {
      _showErrorSnackBar('Please select offense type');
      return;
    }

    if (_offenseDetailsController.text.isEmpty) {
      _showErrorSnackBar('Please enter offense details');
      return;
    }

    if (_fineController.text.isEmpty) {
      _showErrorSnackBar('Please enter fine amount');
      return;
    }

    if (_pointController.text.isEmpty) {
      _showErrorSnackBar('Please enter point amount');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      String? token = await AuthService.getToken();

      final Map<String, dynamic> requestData = {
        'offense_type': _selectedOffenseType,
        'details_offense': _offenseDetailsController.text.trim(),
        'fine': int.tryParse(_fineController.text) ?? 0,
        'point': int.tryParse(_pointController.text) ?? 0,
      };

      debugPrint('Update request data: $requestData');

      final response = await http.put(
        Uri.parse('${Urls.baseUrl}/officer/update-offense/${widget.offenseId}'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(requestData),
      );

      debugPrint('Update response status: ${response.statusCode}');
      debugPrint('Update response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          setState(() {
            _successMessage = data['message'] ?? 'Offense updated successfully!';
          });

          // Show success message and return to previous screen
          _showSuccessSnackBar('Offense updated successfully!');

          // Return true to indicate success
          Navigator.pop(context, true);
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Failed to update offense';
          });
          _showErrorSnackBar(_errorMessage!);
        }
      } else {
        String errorMsg = 'Failed to update offense. Status: ${response.statusCode}';

        try {
          final errorData = json.decode(response.body);
          if (errorData['message'] != null) {
            errorMsg = errorData['message'];
          }
        } catch (e) {
          // Ignore parsing error
        }

        setState(() {
          _errorMessage = errorMsg;
        });
        _showErrorSnackBar(errorMsg);
      }
    } catch (e) {
      debugPrint("Update error: $e");
      setState(() {
        _errorMessage = 'Connection error. Please check your internet connection.';
      });
      _showErrorSnackBar('Connection error. Please try again.');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // Delete offense
  Future<void> _deleteOffense() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Confirm Delete',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this offense? This action cannot be undone.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            child: const Text('Cancel', style: TextStyle(fontSize: 14)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        String? token = await AuthService.getToken();

        final response = await http.delete(
          Uri.parse('${Urls.baseUrl}/officer/delete-offense/${widget.offenseId}'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        );

        debugPrint('Delete response status: ${response.statusCode}');
        debugPrint('Delete response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['success'] == true) {
            _showSuccessSnackBar('Offense deleted successfully!');

            // Return true to indicate successful deletion
            Navigator.pop(context, true);
          } else {
            _showErrorSnackBar(data['message'] ?? 'Failed to delete offense');
          }
        } else {
          _showErrorSnackBar('Failed to delete offense. Status: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint("Delete error: $e");
        _showErrorSnackBar('Connection error. Please try again.');
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // Update fine and point when offense type changes
  void _updateOffenseValues(String offenseType) {
    if (offenseType.isNotEmpty && _offenseData.containsKey(offenseType)) {
      setState(() {
        _fineController.text = _offenseData[offenseType]!['fine']!.toString();
        _pointController.text = _offenseData[offenseType]!['point']!.toString();
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Offense'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          // Delete button in app bar
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isSubmitting ? null : _deleteOffense,
            tooltip: 'Delete Offense',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : _errorMessage != null && _driverId == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOffenseData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver Info Card
            if (_driverName != null)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Driver Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Name: $_driverName'),
                      if (_thanaName != null) Text('Thana: $_thanaName'),
                      if (_officerName != null) Text('Officer: $_officerName'),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Offense Type
            const Text(
              'Offense Type *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedOffenseType.isEmpty ? null : _selectedOffenseType,
                  hint: const Text('Select Offense Type'),
                  isExpanded: true,
                  items: _offenseData.keys.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedOffenseType = value ?? '';
                      _updateOffenseValues(_selectedOffenseType);
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Offense Details
            const Text(
              'Detailed Offense *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _offenseDetailsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter detailed offense description...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Fine Amount
            const Text(
              'Fine (৳) *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _fineController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.attach_money),
                hintText: 'Enter fine amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Point
            const Text(
              'Point *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pointController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.stars),
                hintText: 'Enter point amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info: Fine and point will auto-update based on offense type
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fine and point will auto-update when you select an offense type. You can also edit them manually.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () {
                      Navigator.pop(context, false);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),

                // Update Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _updateOffense,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text('Update', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),

            // Delete button at bottom (alternative)
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _isSubmitting ? null : _deleteOffense,
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  'Delete Offense',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}